export class ComputerRequest {
  constructor(
    public id: number,
    public name: string,
    public modemSide: string,
    public monitorSide: string,
    public redstoneSide: string
  ) { }
}
