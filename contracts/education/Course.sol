// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Lesson.sol";

contract Course is Lesson {

    struct CourseMetadata {
        string  name;
        string  description;
        uint    credits;
        uint256 created;
        uint[] lessons;
        uint256 cost;
        address teacher;
    }

    CourseMetadata[] private courses;

    function createCourse(string memory name, string memory description, uint credits, uint256 cost)
        public
        isTeacher
        returns (uint)
    {
        uint[] memory empty;
        courses[courses.length] = CourseMetadata({
            name: name,
            description: description,
            credits: credits,
            created: block.timestamp,
            lessons: empty,
            cost: cost,
            teacher: msg.sender
        });
        return courses.length;
    }

    function getCourse(uint index)
        public
        view
        returns (CourseMetadata memory)
    {
        return courses[index];
    }

    function getCourses()
        public
        view
        returns (CourseMetadata[] memory)
    {
        return courses;
    }

    function addLesson(uint course,uint lesson)
        public
        isTeacher
    {
        courses[course].lessons[courses[course].lessons.length] = lesson;
    }
}