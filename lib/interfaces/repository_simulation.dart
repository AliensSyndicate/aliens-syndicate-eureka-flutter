import '../models/model_simulation.dart';

abstract interface class SimulationRepository {
  SimulationSession? loadActive();
  Future<void> saveActive(SimulationSession session);
  Future<void> clearActive();
}
