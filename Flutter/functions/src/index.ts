/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as moment from "moment";

admin.initializeApp();

exports.sendNotification = functions.firestore
  .document("woke_up_collection/{docId}")
  .onUpdate((change, context) => {
    const todayId = moment().format("YYYY-MM-DD");
    const updatedDocId = context.params.docId;

    if (updatedDocId === todayId) {
      const payload = {
        notification: {
          title: "Night Light",
          body: "A new activity was detected",
        },
      };
      try {
        admin.messaging().sendToTopic("all", payload)
          .then((response) => {
            console.log("Successfully sent message:", response);
            return null;
          })
          .catch((error) => {
            console.log("Error sending message:", error);
          });
      } catch (error) {
        console.error("error sending message");
      }
    }
    return null;
  });
