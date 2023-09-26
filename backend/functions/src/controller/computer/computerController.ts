import {Express, Request, Response} from "express";
import {ComputerService} from "../../domain/service/computer/computerService";
import {BaseController} from "../base/baseController";
import {getDefaultRouter, TypedRequest} from "../util/express";
import {Computer} from "../../repository/model/computer";

export class ComputerController extends BaseController {
  getRouter(): Express {
    const router = getDefaultRouter();
    router.get("/list", this.list);
    router.post("/register", this.register);
    router.post("/update", this.update);

    router.delete("/:computerId", this.delete);
    router.get("/:computerId", this.find);
    return router;
  }

  delete(
      request: Request,
      response: Response
  ) {
    super.watch(
        response,
        new ComputerService().delete(Number(request.params.computerId)),
        200
    );
  }

  find(
      request: Request,
      response: Response
  ) {
    super.watch(
        response,
        new ComputerService().find(Number(request.params.computerId)),
        200
    );
  }

  list(
      request: Request,
      response: Response
  ) {
    const queryParams = request.query.computerTypes;
    const computerTypes = queryParams ?
      queryParams.toString().split(",") : undefined;
    super.watch(
        response,
        new ComputerService().list(computerTypes),
        200
    );
  }

  register(
      request: TypedRequest<Computer>,
      response: Response
  ) {
    super.watchAndValidateBody(
        Computer,
        request,
        response,
        (body) => new ComputerService().register(body),
        200
    );
  }

  update(
      request: TypedRequest<Computer>,
      response: Response
  ) {
    super.watchAndValidateBody(
        Computer,
        request,
        response,
        (body) => new ComputerService().update(body),
        200
    );
  }
}

export function getComputerController(): ComputerController {
  return new ComputerController();
}
