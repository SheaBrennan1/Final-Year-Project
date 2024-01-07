const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.scheduledFunction = functions.pubsub.schedule('every 1 minutes').onRun(async (context) => {
    const now = new Date();
    const expensesRef = admin.database().ref('/expenses');
    const snapshot = await expensesRef.once('value');
    const expenses = snapshot.val();

    for (const userId in expenses) {
        for (const expenseId in expenses[userId]) {
            const expense = expenses[userId][expenseId];
            if (expense.recurrence !== 'Never') {
                const nextDueDate = calculateNextDueDate(expense.date, expense.recurrence);
                if (nextDueDate <= now) {
                    const newExpense = {...expense, recurrence: 'Never', date: now.toISOString()};
                    await expensesRef.child(userId).push(newExpense);
                }
            }
        }
    }

    return null;
});

function calculateNextDueDate(lastDate, recurrence) {
    const date = new Date(lastDate);
    switch (recurrence) {
        case 'Every Minute':
            date.setMinutes(date.getMinutes() + 1);
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
    return date;
}
