// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract NewsFeed {
    string public constant name = string("PressPage.NEWS");

    enum Category {
        Breaking_News,
        Colleges_and_Universities,
        Current_Events,
        Environmental,
        Government,
        Magazines,
        Media,
        Newspapers,
        Politics,
        Regional_News,
        Religion_and_Spirituality,
        Sports,
        Technology,
        Traffic_Roads,
        Weather,
        Weblogs
    }

    address public owner;

    struct StoryNews {
        Category category;
        string   title;
        uint256  epoch;
        string   topic_sentence_1;
        string   topic_sentence_2;
        string   topic_sentence_3;
    }

    mapping (uint256 => StoryNews[]) newslist;

    constructor() {
        owner = msg.sender;
    }

    function addStory(Category _category,string memory _title,uint256 _epoch,string memory _topic1,string memory _topic2,string memory _topic3)
        public
    {
        require(msg.sender == owner,"unauthroized access, owner only");
        StoryNews memory news = StoryNews(_category,_title,_epoch,_topic1,_topic2,_topic3);
        newslist[_epoch].push(news);
    }

    function getStories(uint256 _epoch)
        public
        payable
        returns (StoryNews[] memory)
    {
        require(msg.value == 0.0001 ether,"not enough for payment");
        payable(address(this)).transfer(msg.value);
        return newslist[_epoch];
    }

    function cashOut()
        public
    {
        require(msg.sender == owner,"unauthroized access, owner only");
        require(address(this).balance > 0, "not enough balance to cash out");
        payable(msg.sender).transfer(address(this).balance);
    }
}