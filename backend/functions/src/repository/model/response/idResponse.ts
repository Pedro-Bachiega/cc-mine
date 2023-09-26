import {ObjectId} from "mongodb";

export class IdResponse {
  constructor(public _id: ObjectId) { }
}
