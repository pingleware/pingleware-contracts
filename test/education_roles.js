const EducationRoles = artifacts.require("EducationRoles");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("education/EducationRoles", function (accounts) {
  it("should assert true", async function () {
    await EducationRoles.deployed();
    return assert.isTrue(true);
  }); 
  it("add user as administrator",async function(){
    const educationRoleInstance = await EducationRoles.deployed();
    await educationRoleInstance.addUser(accounts[0],5);
    return assert.isTrue(true);
  })
  it("add student",async function(){
    const educationRoleInstance = await EducationRoles.deployed();
    await educationRoleInstance.addStudent(accounts[1]);
    return assert.isTrue(true);
  })
  it("add teacher",async function(){
    const educationRoleInstance = await EducationRoles.deployed();
    await educationRoleInstance.addTeacher(accounts[2]);
    return assert.isTrue(true);
  })
  it("add lesson planner",async function(){
    const educationRoleInstance = await EducationRoles.deployed();
    await educationRoleInstance.addUser(accounts[0],5);
    await educationRoleInstance.addTeacher(accounts[0]);
    await educationRoleInstance.addLessonPlanner(accounts[3]);
    return assert.isTrue(true);
  })
  it("add student assistant",async function(){
    const educationRoleInstance = await EducationRoles.deployed();
    await educationRoleInstance.addUser(accounts[0],5);
    await educationRoleInstance.addTeacher(accounts[0]);
    await educationRoleInstance.addStudentAssistance(accounts[1]);
    return assert.isTrue(true);
  })
});
