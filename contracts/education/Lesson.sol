// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./EducationRoles.sol";

contract Lesson is EducationRoles {

    struct LessonMetadata {
        string name;
        string description;
        string course;
        string subject;
        uint256 created;
        address created_by;
        uint256 duration;
        string[] objectives;
        string[] tasks;
        string[] action_plan;
        string[] materials;
        string[] equipment;
        string[] references;
        string[] homework;
        string[] feedback;
    }

    LessonMetadata[] private lessons;

    function createLesson(string memory name, string memory description, string memory course, string memory subject, uint256 duration)
        external
        isLessonPlanner
        returns (uint256)
    {
        string[] memory empty;

        lessons.push(LessonMetadata({
            name: name,
            description: description,
            course: course,
            subject: subject,
            created: block.timestamp,
            created_by: msg.sender,
            duration: duration,
            objectives: empty,
            tasks: empty,
            action_plan: empty,
            materials: empty,
            equipment: empty,
            references: empty,
            homework: empty,
            feedback: empty
        }));
        return lessons.length;
    }

    function getLesson(uint index)
        public
        view
        returns (LessonMetadata memory)
    {
        return lessons[index];
    }

    function getLessons()
        public
        view
        returns (LessonMetadata[] memory)
    {
        return lessons;
    }

    function addObjective(uint index, string memory objective)
        public
        isLessonPlanner
        returns (uint256)
    {
        require(lessons[index].created_by == msg.sender,"not the lesson planner who created this lesson");
        lessons[index].objectives[lessons[index].objectives.length] = objective;
        return lessons[index].objectives.length;
    }

    function addTask(uint index, string memory task)
        public
        isLessonPlanner
        returns (uint256)
    {
        require(lessons[index].created_by == msg.sender,"not the lesson planner who created this lesson");
        lessons[index].tasks[lessons[index].tasks.length] = task;
        return lessons[index].tasks.length;
    }

    function addActionPlan(uint index, string memory plan)
        public
        isLessonPlanner
        returns (uint256)
    {
        require(lessons[index].created_by == msg.sender,"not the lesson planner who created this lesson");
        lessons[index].action_plan[lessons[index].action_plan.length] = plan;
        return lessons[index].action_plan.length;
    }

    function addMaterial(uint index, string memory material)
        public
        isLessonPlanner
        returns (uint256)
    {
        require(lessons[index].created_by == msg.sender,"not the lesson planner who created this lesson");
        lessons[index].materials[lessons[index].materials.length] = material;
        return lessons[index].materials.length;
    }

    function addEquipment(uint index, string memory equipment)
        public
        isLessonPlanner
        returns (uint256)
    {
        require(lessons[index].created_by == msg.sender,"not the lesson planner who created this lesson");
        lessons[index].equipment[lessons[index].equipment.length] = equipment;
        return lessons[index].equipment.length;
    }

    function addReference(uint index, string memory _reference)
        public
        isLessonPlanner
        returns (uint256)
    {
        require(lessons[index].created_by == msg.sender,"not the lesson planner who created this lesson");
        lessons[index].references[lessons[index].references.length] = _reference;
        return lessons[index].references.length;
    }

    function addHomework(uint index, string memory homework)
        public
        isLessonPlanner
        returns (uint256)
    {
        require(lessons[index].created_by == msg.sender,"not the lesson planner who created this lesson");
        lessons[index].homework[lessons[index].homework.length] = homework;
        return lessons[index].homework.length;
    }

    function addFeedback(uint index, string memory feedback)
        public
        isLessonPlanner
        returns (uint256)
    {
        require(lessons[index].created_by == msg.sender,"not the lesson planner who created this lesson");
        lessons[index].feedback[lessons[index].feedback.length] = feedback;
        return lessons[index].feedback.length;
    }

}