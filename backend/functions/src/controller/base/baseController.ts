/* eslint-disable @typescript-eslint/no-explicit-any */
import {Response} from "express";
import * as modelIndex from "./../../repository/model/index";
import {TypedRequest} from "../util/express";
import {forceObjectType, is} from "type-forcer";
import {debug} from "../../common/utils/constants";

export class BaseController {
  protected watch<T>(
      response: Response,
      promise: Promise<T>,
      successCode = 201,
      defaultErrorCode = 500
  ) {
    promise
        .then((result) => {
          if (result == null) {
            console.log(`Response: ${successCode}`);
            response.sendStatus(successCode);
          } else {
            console.log(`Response: ${JSON.stringify(result)}`);
            response.send(result);
          }
        })
        .catch((error) => {
          let statusCode = defaultErrorCode;
          if (is("Exception", error)) statusCode = error.statusCode;

          console.log({error: error});
          response.status(statusCode).send({error: error.message});
        });
  }

  protected async watchAndValidateBody<T, R>(
      klass: new (...args: any[]) => T,
      request: TypedRequest<T>,
      response: Response,
      promise: (body: T) => Promise<R>,
      successCode: number,
      defaultErrorCode = 500
  ) {
    try {
      const body = forceObjectType(request.body, klass, modelIndex, debug);
      const result = await promise(body);

      if (result) {
        console.log(`Response: ${JSON.stringify(result)}`);
        response.send(result);
      } else {
        console.log(`Response: ${successCode}`);
        response.sendStatus(successCode);
      }
    } catch (error: any) {
      let statusCode = defaultErrorCode;
      if (is("Exception", error)) statusCode = error.statusCode;

      console.log({error: error});
      response.status(statusCode).send({error: error.message});
    }
  }
}
