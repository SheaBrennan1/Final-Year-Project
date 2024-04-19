const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.scheduledFunction = functions.pubsub.schedule('every 1 minutes').onRun(async (context) => {
    const now = new Date();
    console.log(`Function triggered at: ${now.toISOString()}`); // Log the current time at function start

    const expensesRef = admin.database().ref('/expenses');
    const snapshot = await expensesRef.once('value');
    const expenses = snapshot.val();

    if (!expenses) {
        console.log('No expenses found.'); // Log if no expenses are found in the database
        return null;
    }

    for (const userId in expenses) {
        for (const expenseId in expenses[userId]) {
            const expense = expenses[userId][expenseId];
            if (!expense || expense.recurrence === 'Never') {
                console.log(`Skipping expenseId: ${expenseId} for userId: ${userId} (No expense data or marked as 'Never')`);
                continue;
            }

            console.log(`Processing expenseId: ${expenseId} for userId: ${userId}`);
            const nextDueDate = calculateNextDueDate(now, expense.recurrence);
            console.log(`ExpenseId: ${expenseId}, Next Due Date: ${nextDueDate.toISOString()}, Now: ${now.toISOString()}`);

            if (nextDueDate <= now) {
                console.log(`Creating new expense for expenseId: ${expenseId} as it's due.`);
                const newExpense = {
                    ...expense,
                    date: now.toISOString(),
                    recurrence: getNextRecurrence(expense.recurrence)
                };
                await expensesRef.child(userId).push(newExpense);
            }
        }
    }

    return null;
});

function calculateNextDueDate(lastDate, recurrence) {
    const date = new Date(lastDate);
    switch (recurrence) {
        case 'Every Minute':
            date.setMinutes(date.getMinutes() - 1);
            break;
        case 'Every Day':
            date.setDate(date.getDate() + 1);
            break;
        case 'Every 3 Days':
            date.setDate(date.getDate() + 3);
            break;
        case 'Every Week':
            date.setDate(date.getDate() + 7);
            break;
    }
    console.log(`Calculated next due date as: ${date.toISOString()} for recurrence type: ${recurrence}`);
    return date;
}

function getNextRecurrence(recurrence) {
    // Assuming logic to determine the next recurrence
    console.log(`Determining next recurrence for type: ${recurrence}`);
    return 'Never'; // Simplified for this example
}


exports.checkYearlyGoal = functions.database.ref('/expenses/{userId}/{expenseId}')
    .onCreate(async (snapshot, context) => {
        const { userId } = context.params;
        const newEntry = snapshot.val();

        // Fetch the yearly target, total income, and expenses for the current year
        const yearlyTargetSnapshot = await admin.database().ref(`yearlyTargets/${userId}`).once('value');
        const yearlyTarget = yearlyTargetSnapshot.val() || 0; // Default to 0 if not set

        // Calculate total income and expenses for the current year
        const totalIncomeAndExpenses = await calculateTotalIncomeAndExpensesForCurrentYear(userId);

        // Check if the goal is met
        const netSavings = totalIncomeAndExpenses.income - totalIncomeAndExpenses.expenses;
        if (netSavings >= yearlyTarget) {
            // Goal is met, send a notification
            await notifyUserYearlyGoalReached(userId, yearlyTarget);
        }
    });

exports.onExpenseAdded = functions.database.ref('/expenses/{userId}/{expenseId}')
    .onCreate(async (snapshot, context) => {
        const { userId } = context.params;
        const newExpense = snapshot.val();

        // First, check if budget warnings are enabled for this user
        const budgetWarningEnabled = await checkIfBudgetWarningsEnabled(userId);
        if (!budgetWarningEnabled) {
            console.log('Budget warnings are disabled for this user:', userId);
            return; // Exit the function if budget warnings are disabled
        }

        // Check if the budget is overused
        const budgetOveruseDetails = await checkIfBudgetOverused(userId, newExpense);

        if(newExpense.type === 'Expense') {
        if (budgetOveruseDetails.isOverused) {
            await notifyUserAboutBudgetOveruse(userId, budgetOveruseDetails.overusedAmount, budgetOveruseDetails.overusedBudgetName);
        }        
    }
    });

    async function checkIfBudgetWarningsEnabled(userId) {
        // Retrieve the user's settings from Firestore to check if budget warnings are enabled
        const userSettingsRef = admin.firestore().collection('userSettings').doc(userId);
        const doc = await userSettingsRef.get();
    
        if (!doc.exists) {
            console.log('No user settings found for:', userId);
            return false; // Default to false if no settings are found
        }

        const userSettings = doc.data();
        console.log("budgetnot stting" + userSettings.budgetWarningsEnabled);
        return userSettings.budgetWarningsEnabled; // Assumes there is a 'budgetWarningsEnabled' field
    }

    async function checkIfBudgetOverused(userId, newExpense) {
        const userBudgetsRef = admin.firestore().collection(`budgets/${userId}/userBudgets`);
        const budgetsSnapshot = await userBudgetsRef.get();
        let isOverused = false;
        let overusedAmount = 0;
        let overusedBudgetName = ""; // Add this line
    
        for (const budgetDoc of budgetsSnapshot.docs) {
            const budget = budgetDoc.data();
            const totalExpenses = await calculateTotalExpensesForBudget(userId, budget.id, budget.startDate, budget.endDate);
            const budgetTotal = Object.values(budget.categoryAllocations).reduce((sum, value) => sum + value, 0);
    
            if (totalExpenses + newExpense.amount > budgetTotal) {
                isOverused = true;
                overusedAmount = (totalExpenses + newExpense.amount) - budgetTotal;
                overusedBudgetName = budget.name; // Assume your budget object has a 'name' field
                break; // Exiting the loop after finding the first overused budget
            }
        }
    
        return { isOverused, overusedAmount, overusedBudgetName }; // Return the budget name as well
    }

    async function calculateTotalExpensesForBudget(userId, budgetId, startDate, endDate) {
        const expensesRef = admin.database().ref(`/expenses/${userId}`);
        const expensesSnapshot = await expensesRef.once('value');
        let totalExpenses = 0;
    
        if (expensesSnapshot.exists()) {
            const expenses = expensesSnapshot.val();
            for (const expenseId in expenses) {
                const expense = expenses[expenseId];
                const expenseDate = new Date(expense.date);
                const budgetEndDate = new Date(endDate);
    
                if (expenseDate >= new Date(startDate) && expenseDate <= budgetEndDate) {
                    const expenseBudgetId = expense.id; // Assuming expense object contains a 'budgetId' field
                    if (expenseBudgetId === budgetId) { // Checking if expense belongs to the specified budget
                        const categoryAllocation = expense.categoryAllocation; // Assuming expense object contains a 'categoryAllocation' field
    
                        // Checking if the expense category is allocated in the budget
                        if (categoryAllocation in categoryAllocations) {
                            totalExpenses += expense.amount;
                        }
                    }
                }
            }
        }
    
        return totalExpenses;
    }
    

async function notifyUserAboutBudgetOveruse(userId, overusedAmount, overusedBudgetName) {
    // Retrieve the user's FCM token from Firestore
    const userRef = admin.firestore().collection('userSettings').doc(userId);
    const doc = await userRef.get();
    
    if (!doc.exists) {
        console.log('No user settings found for user:', userId);
        return;
    }

    const userSettings = doc.data();
    console.log(`User Settings: ${JSON.stringify(userSettings)}`);

    const token = userSettings.fcmToken;
    console.log(`Token: ` + token);

    console.log(`FCM Token for user ${userId}: ${token}`);

    const message = {
        notification: {
            title: 'Budget Alert!',
            body: `The budget plan "${overusedBudgetName}" has been overspent. Consider reviewing your expenses.`,
        },
        data: {
            budgetName: overusedBudgetName,
            type: 'BUDGET_OVERUSE',
          },
        token: token,
    };

    // Send the message
    admin.messaging().send(message)
        .then((response) => {
            console.log('Successfully sent notification:', response);
        })
        .catch((error) => {
            console.error('Error sending notification:', error);
        });
}



function getReminderMinutesBefore(reminder) {
    switch (reminder) {
        case '1 Minute Before':
            return 1;
        case '1 Day Before':
            return 24 * 60; // 24 hours
        default:
            return 0;
    }
}

async function sendNotification(userId, expense) {
    // Retrieve user's FCM token from database or wherever it's stored
    const userSnapshot = await admin.database().ref(`/users/${userId}`).once('value');
    const user = userSnapshot.val();
    if (user && user.fcmToken) {
        const message = {
            notification: {
                title: 'Expense Reminder',
                body: `Don't forget: ${expense.description} is due soon!`,
            },
            token: user.fcmToken,
        };

        // Send the message
        admin.messaging().send(message)
            .then((response) => {
                console.log('Notification sent successfully:', response);
            })
            .catch((error) => {
                console.error('Error sending notification:', error);
            });
    } else {
        console.log('User FCM token not found or user does not exist:', userId);
    }
}

/*exports.checkYearlyGoal = functions.database.ref('/expenses/{userId}/{expenseId}')
    .onCreate(async (snapshot, context) => {
        const { userId } = context.params;
        const newEntry = snapshot.val();

        // Fetch the yearly target, total income, and expenses for the current year
        const yearlyTargetSnapshot = await admin.database().ref(`yearlyTargets/${userId}`).once('value');
        const yearlyTarget = yearlyTargetSnapshot.val() || 0; // Default to 0 if not set

        const yearlyTotalEnabled = await checkIfYearlyTotatNotificationEnabled(userId);
        if (!yearlyTotalEnabled) {
            console.log('Yearly target notifications are disabled for this user:', userId);
            return; // Exit the function if budget warnings are disabled
        }

        // Calculate total income and expenses for the current year
        const totalIncomeAndExpenses = await calculateTotalIncomeAndExpensesForCurrentYear(userId);

        // Check if the goal is met
        const netSavings = totalIncomeAndExpenses.income - totalIncomeAndExpenses.expenses;
        if (netSavings >= yearlyTarget) {
            // Goal is met, send a notification
            await notifyUserYearlyGoalReached(userId, yearlyTarget);
        }
    });*/

    async function checkIfYearlyTotatNotificationEnabled(userId) {
        // Retrieve the user's settings from Firestore to check if budget warnings are enabled
        const userSettingsRef = admin.firestore().collection('userSettings').doc(userId);
        const doc = await userSettingsRef.get();
    
        if (!doc.exists) {
            console.log('No user settings found for:', userId);
            return false; // Default to false if no settings are found
        }
    
        const userSettings = doc.data();
        return userSettings.spendingGoalNotificationsEnabled; // Assumes there is a 'budgetWarningsEnabled' field
    }

async function calculateTotalIncomeAndExpensesForCurrentYear(userId) {
    let income = 0;
    let expenses = 0;
    const year = new Date().getFullYear();
    const expensesSnapshot = await admin.database().ref(`/expenses/${userId}`).once('value');
    
    if (expensesSnapshot.exists()) {
        expensesSnapshot.forEach(childSnapshot => {
            const entry = childSnapshot.val();
            const entryYear = new Date(entry.date).getFullYear();
            if (entryYear === year) {
                if (entry.type === 'Income') {
                    income += entry.amount;
                } else if (entry.type === 'Expense') {
                    expenses += entry.amount;
                }
            }
        });
    }

    return { income, expenses };
}

async function notifyUserYearlyGoalReached(userId, yearlyTarget) {
    // Retrieve the user's FCM token from Firestore
    const userRef = admin.firestore().collection('userSettings').doc(userId);
    const doc = await userRef.get();
    
    if (!doc.exists) {
        console.log(`No user settings found for user: ${userId}`);
        return;
    }

    console.log(`Fetching user settings for user: ${userId}`);

    const userSettings = doc.data();
    console.log(`User Settings: ` + userSettings);

    console.log(`User Settings: ${JSON.stringify(userSettings)}`);


    const token = userSettings.fcmToken;
    console.log(`Token: ` + token);

    console.log(`FCM Token for user ${userId}: ${token}`);


    // Customize the notification message
    const message = {
        notification: {
            title: 'Savings Goal Achieved! 🎉',
            body: `Congratulations! You've reached your savings goal of £${yearlyTarget}. Great job on your financial discipline.`,
        },
        data: {
            // Any additional data you want to send
            type: 'YEARLY_GOAL_ACHIEVED',
            yearlyTarget: yearlyTarget.toString(),
        },
        token: token,
    };

    // Send the notification
    admin.messaging().send(message)
        .then((response) => {
            console.log('Successfully sent savings goal achieved notification:', response);
        })
        .catch((error) => {
            console.error('Error sending savings goal achieved notification:', error);
        });
}


