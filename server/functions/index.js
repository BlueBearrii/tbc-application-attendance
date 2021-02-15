const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.scheduledFunction = functions.pubsub
    .schedule("every day 22:00")
    .timeZone("Asia/Bangkok")
    .onRun((context) => {
    // eslint-disable-next-line max-len
      db.collection("approve")
          .get()
          .then(function(querySnapshot) {
            querySnapshot.forEach(function(doc) {
              doc.ref.update({
                approveState: false,
              });
            });
          })
          .then(function() {
            db.collection("check_in_switch")
                .get()
                .then(function(querySnapshot) {
                  querySnapshot.forEach(function(doc) {
                    doc.ref.update({
                      checkInSwitch: false,
                      checkInState: true,
                    });
                  });
                });
          });

      return console.log("This will be run every minute!");
    });


exports.scheduledFunctionOpenSystem = functions.pubsub
    .schedule("every day 7:00")
    .timeZone("Asia/Bangkok")
    .onRun((context) => {
    // eslint-disable-next-line max-len
      db.collection("check_in_switch")
          .get()
          .then(function(querySnapshot) {
            querySnapshot.forEach(function(doc) {
              doc.ref.update({
                checkInSwitch: false,
                checkInState: false,
              });
            });
          });

      return console.log("This will be run every minute!");
    });

