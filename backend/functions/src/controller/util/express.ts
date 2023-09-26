import * as express from "express";

export interface TypedRequest<T> extends express.Request {
    body: T
}

export function getDefaultRouter(): express.Express {
  const router = express();
  router.use(express.json());
  router.use(express.urlencoded({extended: true}));
  return router;
}
