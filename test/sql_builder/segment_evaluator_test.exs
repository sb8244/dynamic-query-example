defmodule SqlBuilder.SegmentEvaluatorTest do
  use SqlBuilder.DataCase, async: true

  import Ecto.Query
  alias SqlBuilder.SegmentEvaluator
  alias SqlBuilder.Schema.{SegmentCriteria, SegmentLogic}

  describe "to_sql/1" do
    test "empty criteria is open access" do
      logic = logic(:empty)
      expected = dynamic(true)
      assert dynamic_match?(SegmentEvaluator.to_sql(logic), expected)
    end

    test "a top-level AND connective with a single criteria" do
      logic = logic(:single_and)

      expected = dynamic([w], w.name == ^"test")
      assert dynamic_match?(SegmentEvaluator.to_sql(logic), expected)
    end

    test "a top-level AND connective with multiple criteria" do
      logic = logic(:multi_criteria)

      expected = dynamic([w, c], c.name == ^"Acme" and w.name == ^"French Press")
      assert dynamic_match?(SegmentEvaluator.to_sql(logic), expected)
    end

    test "!= is evaluated properly" do
      logic = logic(:not_equal)

      expected = dynamic([w, c], c.name != ^"Acme" and w.name != ^"Stove")
      assert dynamic_match?(SegmentEvaluator.to_sql(logic), expected)
    end

    test "multiple logics connected with AND are combined" do
      logic = logic(:multi_and)

      expected = dynamic([w, c], w.name == ^"Chair" and c.type == ^"Corporate")
      assert dynamic_match?(SegmentEvaluator.to_sql(logic), expected)
    end

    test "multiple logics connected with OR are combined" do
      logic = logic(:multi_or)

      expected = dynamic([w, c], w.name == ^"Chair" or c.type == ^"Indie")
      assert dynamic_match?(SegmentEvaluator.to_sql(logic), expected)
    end

    test "logic and criteria can be combined" do
      logic = logic(:combine_types, "AND")
      expected = dynamic([w], (w.name == ^"o1" or w.name == ^"o2") and (w.name == ^"a1" and w.name == ^"a2"))
      assert dynamic_match?(SegmentEvaluator.to_sql(logic), expected)

      logic = logic(:combine_types, "OR")
      expected = dynamic([w], w.name == ^"o1" or w.name == ^"o2" or (w.name == ^"a1" or w.name == ^"a2"))
      assert dynamic_match?(SegmentEvaluator.to_sql(logic), expected)
    end

    test "complex nested logic evaluates properly" do
      logic = logic(:comprehensive)

      expected =
        dynamic(
          [w, c],
          ((w.name == ^"A" and c.name == ^"A") or (w.name == ^"B" or c.name == ^"B") or w.name == ^"C") and
            (c.type == ^"D" and w.type == ^"D") and (c.external_id == ^"E" and w.external_id == ^"E")
        )

      assert dynamic_match?(SegmentEvaluator.to_sql(logic), expected)
    end

    test "randomly generated logic evaluates" do
      # This is not quite a prop test. The random_logic/1 function generates a random logic
      # based on the rules of what is allowed. So all of the different code paths will be
      # exercised through it.
      #
      # This is tested against the database (which is empty) to ensure that Postgres will run the query
      #
      # Want to write a real prop test? This is the place to try it out!
      for _ <- 1..10 do
        logic = random_logic(Enum.random(0..5))
        conditions = SegmentEvaluator.to_sql(logic)

        query = SqlBuilder.widget_creator_query()
        query = Ecto.Query.where(query, ^conditions)
        assert Repo.all(query) == []
      end
    end
  end

  defp dynamic_match?(dynamic, expected) do
    # Ecto docs show this as the best way to test dynamics, due to how they're stored
    inspect(dynamic) == inspect(expected)
  end

  defp logic(:empty) do
    %SegmentLogic{
      connective: "AND",
      segment_logic: [],
      segment_criteria: []
    }
  end

  defp logic(:single_and) do
    %SegmentLogic{
      connective: "AND",
      segment_logic: [],
      segment_criteria: [
        %SegmentCriteria{
          object: "widget",
          object_field: "name",
          operator: "=",
          value: "test"
        }
      ]
    }
  end

  defp logic(:multi_criteria) do
    %SegmentLogic{
      connective: "AND",
      segment_logic: [],
      segment_criteria: [
        %SegmentCriteria{
          object: "creator",
          object_field: "name",
          operator: "=",
          value: "Acme"
        },
        %SegmentCriteria{
          object: "widget",
          object_field: "name",
          operator: "=",
          value: "French Press"
        }
      ]
    }
  end

  defp logic(:not_equal) do
    %SegmentLogic{
      connective: "AND",
      segment_logic: [],
      segment_criteria: [
        %SegmentCriteria{
          object: "creator",
          object_field: "name",
          operator: "!=",
          value: "Acme"
        },
        %SegmentCriteria{
          object: "widget",
          object_field: "name",
          operator: "!=",
          value: "Stove"
        }
      ]
    }
  end

  defp logic(:multi_and) do
    %SegmentLogic{
      connective: "AND",
      segment_logic: [
        %SegmentLogic{
          connective: "AND",
          segment_criteria: [
            %SegmentCriteria{
              object: "widget",
              object_field: "name",
              operator: "=",
              value: "Chair"
            }
          ]
        },
        %SegmentLogic{
          connective: "AND",
          segment_criteria: [
            %SegmentCriteria{
              object: "creator",
              object_field: "type",
              operator: "=",
              value: "Corporate"
            }
          ]
        }
      ],
      segment_criteria: []
    }
  end

  defp logic(:multi_or) do
    %SegmentLogic{
      connective: "OR",
      segment_logic: [
        %SegmentLogic{
          connective: "OR",
          segment_criteria: [
            %SegmentCriteria{
              object: "widget",
              object_field: "name",
              operator: "=",
              value: "Chair"
            }
          ]
        },
        %SegmentLogic{
          connective: "AND",
          segment_criteria: [
            %SegmentCriteria{
              object: "creator",
              object_field: "type",
              operator: "=",
              value: "Indie"
            }
          ]
        }
      ],
      segment_criteria: []
    }
  end

  defp logic(:comprehensive) do
    %SegmentLogic{
      connective: "AND",
      segment_logic: [
        %SegmentLogic{
          connective: "OR",
          segment_logic: [
            %SegmentLogic{
              connective: "AND",
              segment_criteria: [
                %SegmentCriteria{
                  object: "widget",
                  object_field: "name",
                  operator: "=",
                  value: "A"
                },
                %SegmentCriteria{
                  object: "creator",
                  object_field: "name",
                  operator: "=",
                  value: "A"
                }
              ]
            },
            %SegmentLogic{
              connective: "OR",
              segment_criteria: [
                %SegmentCriteria{
                  object: "widget",
                  object_field: "name",
                  operator: "=",
                  value: "B"
                },
                %SegmentCriteria{
                  object: "creator",
                  object_field: "name",
                  operator: "=",
                  value: "B"
                }
              ]
            }
          ],
          segment_criteria: [
            %SegmentCriteria{
              object: "widget",
              object_field: "name",
              operator: "=",
              value: "C"
            }
          ]
        },
        %SegmentLogic{
          connective: "AND",
          segment_criteria: [
            %SegmentCriteria{
              object: "creator",
              object_field: "type",
              operator: "=",
              value: "D"
            },
            %SegmentCriteria{
              object: "widget",
              object_field: "type",
              operator: "=",
              value: "D"
            }
          ]
        }
      ],
      segment_criteria: [
        %SegmentCriteria{
          object: "creator",
          object_field: "external_id",
          operator: "=",
          value: "E"
        },
        %SegmentCriteria{
          object: "widget",
          object_field: "external_id",
          operator: "=",
          value: "E"
        }
      ]
    }
  end

  defp logic(:combine_types, connective) do
    %SegmentLogic{
      connective: connective,
      segment_logic: [
        %SegmentLogic{
          connective: "OR",
          segment_criteria: [
            %SegmentCriteria{
              object: "widget",
              object_field: "name",
              operator: "=",
              value: "o1"
            },
            %SegmentCriteria{
              object: "widget",
              object_field: "name",
              operator: "=",
              value: "o2"
            }
          ]
        }
      ],
      segment_criteria: [
        %SegmentCriteria{
          object: "widget",
          object_field: "name",
          operator: "=",
          value: "a1"
        },
        %SegmentCriteria{
          object: "widget",
          object_field: "name",
          operator: "=",
          value: "a2"
        }
      ]
    }
  end

  defp random_logic(depth_remaining) do
    sublogic_count = :rand.uniform(5) - 1
    criteria_count = :rand.uniform(5) - 1

    criteria =
      for i <- 1..criteria_count, i > 0 do
        object = Enum.random(SegmentCriteria.valid_objects())
        object_field = Enum.random(SegmentCriteria.valid_fields(object))

        %SegmentCriteria{
          object: object,
          object_field: object_field,
          operator: Enum.random(["=", "!="]),
          value: random_string()
        }
      end

    sublogics =
      for i <- 1..sublogic_count, i > 0, depth_remaining > 0 do
        random_logic(depth_remaining - 1)
      end

    %SegmentLogic{
      connective: Enum.random(["AND", "OR"]),
      segment_criteria: criteria,
      segment_logic: sublogics
    }
  end

  defp random_string do
    Enum.random(1..20)
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end
end
