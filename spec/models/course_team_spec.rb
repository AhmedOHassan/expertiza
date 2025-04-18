describe 'CourseTeam' do
  let(:course_team1) { build(:course_team, id: 1, name: 'no team') }
  let(:user2) { build(:student, id: 2, name: 'no name') }
  let(:participant) { build(:participant, user: user2) }
  let(:course) { build(:course, id: 1, name: 'ECE517') }
  let(:team_user) { build(:team_user, id: 1, user: user2) }
  describe 'copy course team to assignment team' do
    it 'should allow course team to be copied to assignment team' do
      assignment = build(Assignment)
      assignment.name = 'test'
      assignment.save!
      assignment_team = AssignmentTeam.new
      assignment_team.save
      course_team = CourseTeam.new
      course_team.copy_to_assignment(assignment_team.id)
      expect(AssignmentTeam.create_team_and_node(assignment_team.id))
      expect(assignment_team.copy(assignment_team.id))
    end
  end
  describe '#assignment_id' do
    it 'returns nil since this team is not an assignment team' do
      course_team = CourseTeam.new
      expect(course_team.assignment_id).to be_nil
    end
  end
  describe '#import' do
    context 'when the course does not exist' do
      it 'raises an import error' do
        allow(Course).to receive(:find).with(1).and_return(nil)
        expect { CourseTeam.import({}, 1, nil) }.to raise_error(ImportError)
      end
    end
    context 'when the course does exist' do
      it 'raises an error with empty row hash' do
        allow(Course).to receive(:find).with(1).and_return(course)
        expect { CourseTeam.import({}, 1, nil) }.to raise_error(ArgumentError)
      end
    end
  end
  describe '#export' do
    it 'writes to a csv' do
      allow(CourseTeam).to receive(:where).with(parent_id: 1).and_return([course_team1])
      allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
      expect(CourseTeam.export([], 1, team_name: 'false')).to eq([['no team', 'no name']])
    end
  end
  describe '#export_fields' do
    it 'returns a list of headers' do
      expect(CourseTeam.export_fields(team_name: 'false')).to eq(['Team Name', 'Team members', 'Course Name'])
    end
  end
end
