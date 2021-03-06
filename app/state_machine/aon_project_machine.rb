class AonProjectMachine < FlexProjectMachine
  setup_machine do
    transition from: :deleted, to: %i(draft)
    transition from: :rejected, to: %i(draft deleted)
    transition from: :draft, to: %i(rejected deleted online)
    transition from: :online, to: %i(draft rejected deleted waiting_funds successful failed)
    transition from: :waiting_funds, to: %i(successful failed)
    transition from: :failed, to: %i(deleted)

    guard_transition(to: :failed) do |project|
      !project.reached_goal?
    end

    guard_transition(to: :successful) do |project|
      project.reached_goal?
    end
  end
end
