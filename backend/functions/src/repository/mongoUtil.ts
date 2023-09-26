/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  Collection,
  DeleteResult,
  Document,
  Filter,
  MongoClient,
  ObjectId,
  UpdateFilter,
  UpdateResult,
} from "mongodb";
import * as modelIndex from "./model/index";
import {IdResponse} from "./model/response/idResponse";
import {forceObjectType} from "type-forcer";
import {debug} from "../common/utils/constants";

export class MongoUtil {
  private collectionName: string;

  constructor(collectionName: string) {
    this.collectionName = collectionName;
  }

  private async perform<T>(
      action: (collection: Collection<Document>) => Promise<T>
  ): Promise<T> {
    const client = new MongoClient(process.env.MONGO_DB_URI || "");
    await client.connect();

    const collection = client.db("dev").collection(this.collectionName);
    const result = await action(collection);

    client.close();
    return result;
  }

  deleteById(id: string): Promise<DeleteResult> {
    return this.deleteOne({_id: new ObjectId(id)});
  }

  deleteMany(filter: Filter<Document>): Promise<DeleteResult> {
    return this.perform((collection) => collection.deleteMany(filter));
  }

  deleteManyById(ids: string[]): Promise<DeleteResult> {
    return this.perform((collection) => collection.deleteMany(
        {_id: {"$in": ids.map((id) => new ObjectId(id))}}
    ));
  }

  deleteOne(filter: Filter<Document>): Promise<DeleteResult> {
    return this.perform((collection) => collection.deleteOne(filter));
  }

  findOne<T>(
      klass: new (...args: any[]) => T,
      filter: Filter<Document>
  ): Promise<T | null> {
    return this.perform(async (collection) => {
      return (collection.findOne(filter) as Promise<T | null>)
          .then((item) => {
            if (!item) return null;
            return forceObjectType(item, klass, modelIndex, debug);
          });
    });
  }

  findOneById<T>(
      klass: new (...args: any[]) => T,
      id: ObjectId
  ): Promise<T | null> {
    return this.findOne(klass, {_id: id});
  }

  insertOne<T extends Document>(
      model: T
  ): Promise<IdResponse> {
    return this.perform(async (collection) => {
      return collection
          .insertOne(model)
          .then((result) => new IdResponse(result.insertedId));
    });
  }

  insertOneAndGet<T extends Document, R>(
      klass: new (...args: any[]) => R,
      model: T
  ): Promise<R> {
    return this.perform(async (collection) => {
      return collection
          .insertOne(model)
          .then(async (result) => {
            return this.findOneById<R>(klass, result.insertedId)
            // eslint-disable-next-line max-len
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                .then((result) => result!);
          });
    });
  }

  list<T>(
      klass: new (...args: any[]) => T,
      filter: Filter<Document> = {}
  ): Promise<T[]> {
    return this.perform((collection) => {
      return collection
          .find(filter)
          .map((doc) => {
            return forceObjectType<T>(
            doc as unknown as T,
            klass,
            modelIndex,
            debug
            );
          })
          .toArray();
    });
  }

  updateOne(
      filter: Filter<Document>,
      update: UpdateFilter<Document>
  ): Promise<UpdateResult> {
    return this.perform((collection) => collection.updateOne(filter, update));
  }

  replaceOne<T>(
      filter: Filter<T>,
      replace: Document
  ): Promise<Document | UpdateResult> {
    return this.perform((collection) => collection.replaceOne(filter, replace));
  }

  replaceOneAndGet<T>(
      filter: Filter<Document>,
      replace: Document
  ): Promise<T | null> {
    return this.perform(async (collection) => {
      return collection.replaceOne(filter, replace).then((result) => {
        if (!result.acknowledged) return null;
        return replace as unknown as T;
      });
    });
  }
}
