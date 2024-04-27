import {
  ComputerNotFoundException,
  DuplicateComputerException,
} from "../../common/error/exception";
import { Computer } from "../model/computer";
import { MongoUtil } from "../mongoUtil";

export class ComputerRepository {
  constructor(private mongo: MongoUtil = new MongoUtil("computer")) { }

  async delete(computerId: number): Promise<void> {
    await this.mongo.deleteOne({ id: computerId });
  }

  async find(computerId: number): Promise<Computer> {
    const response =
      await this.mongo.findOne(Computer, { id: computerId });

    if (!response) return Promise.reject(new ComputerNotFoundException());
    return response;
  }

  async list(computerTypes?: string[]): Promise<Computer[]> {
    if (!computerTypes || computerTypes.length == 0) {
      return this.mongo.list(Computer);
    }

    return this.mongo.list(
      Computer,
      { computerType: { $in: computerTypes } }
    );
  }

  async register(request: Computer): Promise<void> {
    const response = await this.mongo.findOne(
      Computer,
      { id: request.id }
    );
    if (response) return Promise.reject(new DuplicateComputerException());

    await this.mongo.insertOne(request);
  }
}
