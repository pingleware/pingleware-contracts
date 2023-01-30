// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

contract EducationRoles is Version, Owned {
    enum Role {
        Student,
        StudentAssistant,
        Proctor,
        LessonPlanner,
        Teacher,
        Administrator
    }

    mapping(address => Role) private role;

    modifier isLessonPlanner()
    {
        require(role[msg.sender] == Role.LessonPlanner, "not authorized to plan lessons");
        _;
    }

    modifier isTeacher()
    {
        require(role[msg.sender] == Role.Teacher, "not authorized teacher/instructor");
        _;
    }

    modifier isAdministrator()
    {
        require(role[msg.sender] == Role.Administrator, "not authorized administrator");
        _;
    }

    modifier isStudent()
    {
        require(role[msg.sender] == Role.Student, "not authorized student");
        _;
    }

    function addUser(address user, Role _role)
        public
        okOwner
    {
        role[user] = _role;
    }

    function addStudent(address user)
        public
        isAdministrator
    {
        role[user] = Role.Student;
    }

    function addTeacher(address user)
        public
        isAdministrator
    {
        role[user] = Role.Teacher;
    }

    function addLessonPlanner(address user)
        public
        isTeacher
    {
        role[user] = Role.LessonPlanner;
    }

    function addStudentAssistance(address user)
        public
        isTeacher
    {
        require(role[user] == Role.Student,"not a student");
        role[user] = Role.StudentAssistant;
    }

}