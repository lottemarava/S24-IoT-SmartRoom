import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

exports.sendNotification = functions.firestore
  .document("woke_up_collection/{date_id}")
  .onUpdate(async (change, context) => {
    await admin.messaging().sendToTopic("NightLight", {
      notification: {
        title: "Night Light",
        body: "Night Time Activity Detected",
      },
    });
  });
