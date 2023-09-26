export interface Exception extends Error {
    statusCode: number;
}

export class ComputerNotFoundException implements Exception {
  name = "ComputerNotFoundException";
  message = "Computer not found";
  stack?: string | undefined;
  statusCode = 404;
}

export class CharacterNotFoundException implements Exception {
  name = "CharacterNotFoundException";
  message = "Character not found";
  stack?: string | undefined;
  statusCode = 404;
}

export class DuplicateComputerException implements Exception {
  name = "DuplicateComputerException";
  message = "A computer with this id has already been registered";
  stack?: string | undefined;
  statusCode = 406;
}

export class DuplicateWorldException implements Exception {
  name = "DuplicateWorldException";
  message = "A world with that name already exists";
  stack?: string | undefined;
  statusCode = 406;
}

export class InvalidCredentialsException implements Exception {
  name = "InvalidCredentialsException";
  message = "Invalid credentials";
  stack?: string | undefined;
  statusCode = 501;
}

export class LevelingNotEnabledForCharacterException implements Exception {
  name = "LevelingNotEnabledForCharacterException";
  message = "Leveling is not enabled for this character";
  stack?: string | undefined;
  statusCode = 500;
}

export class MissingFieldsException implements Exception {
  name = "MissingFieldsException";
  message;
  stack?: string | undefined;
  statusCode = 400;

  constructor(fieldName: string) {
    this.message = `Field ${fieldName} is missing`;
  }
}

export class MissionAlreadyStartedException implements Exception {
  name = "MissionAlreadyStartedException";
  message = "Mission was already started";
  stack?: string | undefined;
  statusCode = 406;
}

export class UnauthorizedException implements Exception {
  name = "UnauthorizedException";
  message = "Unauthorized";
  stack?: string | undefined;
  statusCode = 401;
}

export class WorldNotFoundException implements Exception {
  name = "WorldNotFoundException";
  message = "World not found";
  stack?: string | undefined;
  statusCode = 404;
}
