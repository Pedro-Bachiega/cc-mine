import {ObjectId} from "mongodb";

export class ComputerResponse {
  constructor(
    public _id: ObjectId,
    public id: number,
    public name: string,
    public modemSide: string,
    public monitorSide: string,
    public redstoneSide: string
  ) { }
}
