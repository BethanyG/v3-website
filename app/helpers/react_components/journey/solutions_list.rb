module ReactComponents
  module Journey
    class SolutionsList < ReactComponent
      def to_s
        super(
          "journey-solutions-list",
          {
            endpoint: Exercism::Routes.api_solutions_url
          }
        )
      end
    end
  end
end
