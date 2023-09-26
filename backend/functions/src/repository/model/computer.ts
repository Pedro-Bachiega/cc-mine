export class Computer {
  constructor(
    public id: number,
    public name: string,
    public computerType: string,
    public modemSide: string,
    public monitorSide: string,
    public redstoneSide: string,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    public data?: any
  ) { }
}
