require "test_helper"

class GuageSessionTest < ActiveSupport::TestCase
  def session_for(starts_on, ends_on, by: admins(:owner))
    GuageSession.new(starts_on: starts_on, ends_on: ends_on, created_by: by)
  end

  test "a financial year is valid and labelled across both years" do
    guage_session = session_for(Date.new(2026, 4, 6), Date.new(2027, 4, 5))

    assert guage_session.valid?
    assert_equal "2026–27", guage_session.label
    assert_equal "2026", session_for(Date.new(2026, 1, 1), Date.new(2026, 12, 31)).label
  end

  test "dates must be ordered and span at most a year" do
    assert_includes session_for(Date.new(2026, 5, 1), Date.new(2026, 4, 1)).tap(&:validate).errors[:ends_on],
                    "must be on or after the start date"
    assert_includes session_for(Date.new(2026, 4, 6), Date.new(2027, 4, 6)).tap(&:validate).errors[:ends_on],
                    "must be within a year of the start date"
  end

  test "sessions can't overlap, but can sit back to back" do
    session_for(Date.new(2026, 1, 1), Date.new(2026, 12, 31)).save!

    overlapping = session_for(Date.new(2026, 12, 31), Date.new(2027, 6, 30))
    assert_not overlapping.valid?
    assert_match "overlap the 2026 session", overlapping.errors[:base].first

    assert session_for(Date.new(2027, 1, 1), Date.new(2027, 12, 31)).valid?
  end

  test "the database rejects overlaps the validation can't see" do
    session_for(Date.new(2026, 1, 1), Date.new(2026, 12, 31)).save!

    assert_raises(ActiveRecord::StatementInvalid) do
      session_for(Date.new(2026, 6, 1), Date.new(2027, 5, 31)).save!(validate: false)
    end
  end

  test "only owners and super users can open a session" do
    assert_not session_for(Date.current, Date.current + 30, by: admins(:one)).valid?
    assert session_for(Date.current, Date.current + 30, by: admins(:super)).valid?
  end

  test "current is the session covering today" do
    session_for(Date.current - 400, Date.current - 40).save!
    current = session_for(Date.current - 10, Date.current + 300).tap(&:save!)

    assert_equal current, GuageSession.current
    assert current.in_progress?
  end
end
