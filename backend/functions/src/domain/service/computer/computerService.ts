import {
  ComputerRepository,
} from "../../../repository/computer/computerRepository";
import {Computer} from "../../../repository/model/computer";

export class ComputerService {
  constructor(
    private repository: ComputerRepository = new ComputerRepository()
  ) { }

  async delete(computerId: number): Promise<void> {
    return this.repository.delete(computerId);
  }

  async find(computerId: number): Promise<Computer> {
    return this.repository.find(computerId);
  }

  async list(computerTypes?: string[]): Promise<Computer[]> {
    return this.repository.list(computerTypes);
  }

  async register(request: Computer): Promise<Computer> {
    await this.repository.register(request);
    return this.find(request.id);
  }

  async update(request: Computer): Promise<Computer> {
    return this.repository.update(request);
  }
}
