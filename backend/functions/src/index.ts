import "dotenv/config";
import "reflect-metadata";
import * as functions from "firebase-functions";
import {
  getComputerController,
} from "./controller/computer/computerController";

const regionalFunctions = functions.region("southamerica-east1");

export const computer = regionalFunctions.https.onRequest(
    getComputerController().getRouter()
);
