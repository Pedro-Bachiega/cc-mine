import {ComputerService} from "./computer/computerService";

export class ServiceProvider {
  getComputerService(): ComputerService {
    return new ComputerService();
  }
}
