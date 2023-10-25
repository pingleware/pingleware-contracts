// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Course.sol";

contract Transcripts is Course {

    struct Grade {
        CourseMetadata course;
        string grade;
    }

    struct Semester {
        uint256 starting;
        uint256 ending;
    }

    struct Transcript {
        mapping(uint256 => Grade[]) grades;
    }

    mapping (address => Transcript) private _transcript;
    Semester[] private semester;

    function newSemester(uint256 _start,uint256 _end)
        public
        isAdministrator
        returns (uint)
    {
        semester.push(Semester({
            starting: _start,
            ending: _end
        }));
        return semester.length;
    }

    function getSemester(uint index)
        public
        view
        returns (Semester memory)
    {
        return semester[index];
    }

    function getSemesters()
        public
        view
        returns (Semester[] memory)
    {
        return semester;
    }

    function registerCourse(uint _semester, uint _course)
        public
        payable
        isStudent
        returns (uint)
    {
        require(block.timestamp >= semester[_semester].starting && block.timestamp < semester[_semester].ending,"outside registration/semester window");
        CourseMetadata memory course = getCourse(_course);
        require(msg.value >= course.cost,"insufficient monies to register for course");
        LessonMetadata memory lesson = getLesson(0);
        address lesson_planner = lesson.created_by;
        uint256 payment = course.cost / 3;
        payable(address(this)).transfer(payment);
        payable(course.teacher).transfer(payment);
        payable(lesson_planner).transfer(payment);
        _transcript[msg.sender].grades[_semester][_transcript[msg.sender].grades[_semester].length] = Grade({
            course: course,
            grade: "Pending"
        });
        return _transcript[msg.sender].grades[_semester].length;
    }

    function dropCourse(uint _semester, uint _course)
        public
        isStudent
        returns (uint)
    {
        require(block.timestamp >= semester[_semester].starting && block.timestamp < semester[_semester].ending,"outside registration/semester drop window");
        delete _transcript[msg.sender].grades[_semester][_course];
        return _transcript[msg.sender].grades[_semester].length;
    }

    function gradeCourse(uint _semester, uint _course, address student, string memory grade)
        public
        isTeacher
    {
        CourseMetadata memory course = getCourse(_course);
        require(course.teacher == msg.sender,"wrong teacher authorization");
        for(uint i = 0; i < _transcript[student].grades[_semester].length; i++) {
            if (compareStrings(_transcript[student].grades[_semester][i].course.name, course.name)) {
                _transcript[student].grades[_semester][i].grade = grade;
            }
        }
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}