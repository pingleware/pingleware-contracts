const Lesson = artifacts.require("Lesson");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("education/Lesson", function (accounts) {
  it("should assert true", async function () {
    await Lesson.deployed();
    return assert.isTrue(true);
  }); 
  it("create a lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.createLesson("Inroduction","Introduction to Blockchain","Blockchain","Development",1000)
    return assert.isTrue(true);
  })
  it("create a second lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.createLesson("Environment","Setting up Development Environment","Blockchain","Development",1000)
    return assert.isTrue(true);
  })
  it("retrieve the second lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    const lesson = await lessonInstance.getLesson(1);
    return assert.equal(lesson.name,"Environment","expected lesson name to be Environment");
  })
  it("add an objective to the first lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.addObjective(0,"Know the difference between permissioned and permissionless blockchain");
    return assert.isTrue(true);
  })
  it("add a task to the first lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.addTask(0,"Create a contract using owner as the access for all changeable functions");
    return assert.isTrue(true);
  })
  it("add an action plan to the first lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.addActionPlan(0,"This course is for students wishing to explore blockchain technology’s potential use—by entrepreneurs & incumbents—to change the world of money and finance.");
    return assert.isTrue(true);
  })
  it("add material to the first lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.addMaterial(0,"https://ocw.mit.edu/courses/15-s12-blockchain-and-money-fall-2018/video_galleries/video-lectures/");
    return assert.isTrue(true);
  })
  it("add equipment to the first lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.addEquipment(0,"https://snapcraft.io/ethereum-contract-creator");
    return assert.isTrue(true);
  })
  it("add a reference to the first lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.addReference(0,"https://ocw.mit.edu/courses/15-s12-blockchain-and-money-fall-2018/resources/session-9-permissioned-systems/");
    return assert.isTrue(true);
  })
  it("add homework to the first lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.addHomework(0,"https://ocw.mit.edu/courses/15-s12-blockchain-and-money-fall-2018/pages/assignments/");    
    return assert.isTrue(true);
  })
  it("add feedback to the first lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    await lessonInstance.addUser(accounts[0],5);
    await lessonInstance.addTeacher(accounts[0]);
    await lessonInstance.addLessonPlanner(accounts[0]);
    await lessonInstance.addFeedback(0,"https://www.reddit.com/r/CryptoCurrency/comments/lzr76b/learning_mit_open_course_blockchain_and_money/");
    return assert.isTrue(true);
  })
  it("retrieve first lesson",async function(){
    const lessonInstance = await Lesson.deployed();
    const lesson = await lessonInstance.getLesson(0);
    console.log(lesson);
    return assert.isTrue(true);
  })
});
