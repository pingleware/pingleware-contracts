const Course = artifacts.require("Course");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("education/Course", function (accounts) {
  it("should assert true", async function () {
    await Course.deployed();
    return assert.isTrue(true);
  });
  it("create a blockchain course", async function(){
    const courseInstance = await Course.deployed();
    await courseInstance.addUser(accounts[0],5);
    await courseInstance.addTeacher(accounts[0]);
    await courseInstance.createCourse("Blockchain","Blockchain RWA",3,125)
    const course = await courseInstance.getCourse(0);
    return assert.equal(course.name,"Blockchain","expected course name to be Blockchain");
  })
  it("retrieve first course",async function(){
    const courseInstance = await Course.deployed();
    const course = await courseInstance.getCourse(0);
    return assert.equal(course.name,"Blockchain","expected Blockchain as course name");
  })
  it("create a lesson for the Blockchain course",async function(){
    const courseInstance = await Course.deployed();
    await courseInstance.addUser(accounts[0],5);
    await courseInstance.addTeacher(accounts[0]);
    await courseInstance.addLessonPlanner(accounts[0]);
    await courseInstance.createLesson("Introduction","Introduction to the Blockchain","Blockchain","Introduction",1000);
    const lesson = await courseInstance.getLesson(0);
    return assert.equal(lesson.name,"Introduction","expected lessan name to be Introduction");
  })
  it("add first lesson to the first course",async function(){
    const courseInstance = await Course.deployed();
    await courseInstance.addUser(accounts[0],5);
    await courseInstance.addTeacher(accounts[0]);
    await courseInstance.addLesson(0,0);
    const course = await courseInstance.getCourse(0);
    return assert.equal(course.lessons[0],0,"expected to be first lesson");
  })
});
