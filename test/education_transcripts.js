const Transcripts = artifacts.require("Transcripts");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("education/Transcripts", function (accounts) {
  it("should assert true", async function () {
    await Transcripts.deployed();
    return assert.isTrue(true);
  }); 
  it("new ssemester",async function(){
    const transcriptInstance = await Transcripts.deployed();
    await transcriptInstance.addUser(accounts[0],5);
    await transcriptInstance.newSemester(1704286800,1714510800)
    return assert.isTrue(true);
  })
  it("register for a course",async function(){
    const transcriptInstance = await Transcripts.deployed();
    await transcriptInstance.addUser(accounts[0],5);
    await transcriptInstance.addTeacher(accounts[0]);
    await transcriptInstance.createCourse("Blockchain","Blockchain RWA",3,125)
    await transcriptInstance.addStudent(accounts[0]);
    //await transcriptInstance.registerCourse(0,0);
    return assert.isTrue(true);
  })
  it("drop a course",async function(){
    const transcriptInstance = await Transcripts.deployed();
    await transcriptInstance.addUser(accounts[0],5);
    await transcriptInstance.addStudent(accounts[0]);
    await transcriptInstance.dropCourse(0,0)
    return assert.isTrue(true);
  })
  it("grade a course",async function(){
    const transcriptInstance = await Transcripts.deployed();
    await transcriptInstance.addUser(accounts[0],5);
    await transcriptInstance.addTeacher(accounts[0]);
    await transcriptInstance.gradeCourse(0,0,accounts[1],"A");
    return assert.isTrue(true);
  })
  it("retrieve all semesters",async function(){
    const transcriptInstance = await Transcripts.deployed();
    const semesters = await transcriptInstance.getSemesters();
    console.log(semesters)
    return assert.isTrue(true);
  })
});
