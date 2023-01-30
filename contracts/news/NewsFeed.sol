// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Frozen.sol";

contract NewsFeed is Version, Frozen {
    string public constant name = string("PressPage.NEWS");
    string public constant symbol = string("PRESS.NEWS");
    uint256 public totalSupply = 0;

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

    struct CategoryList {
        Category category;
        string   name;
    }

    struct StoryNews {
        address  publisher;
        Category category;
        string   title;
        uint256  epoch;
        string   topic_sentence_1;
        string   topic_sentence_2;
        string   topic_sentence_3;
    }

    mapping(address => mapping (uint256 => StoryNews[])) private newslist;
    mapping (uint256 => address) private storytimes;
    uint256[] private _storytimes;

    CategoryList[] public categories;

    mapping(address => bool) private whitelisted;

    constructor() {
        whitelisted[msg.sender] = true;

        categories.push(CategoryList({
            category: Category.Breaking_News,
            name: "Breaking News"
        }));
        categories.push(CategoryList({
            category: Category.Colleges_and_Universities,
            name: "Colleges & Universities"
        }));
        categories.push(CategoryList({
            category: Category.Current_Events,
            name: "Current Events"
        }));
        categories.push(CategoryList({
            category: Category.Environmental,
            name: "Environmental"
        }));
        categories.push(CategoryList({
            category: Category.Government,
            name: "Government"
        }));
        categories.push(CategoryList({
            category: Category.Magazines,
            name: "Magazines"
        }));
        categories.push(CategoryList({
            category: Category.Media,
            name: "Media"
        }));
        categories.push(CategoryList({
            category: Category.Newspapers,
            name: "Newspapers"
        }));
        categories.push(CategoryList({
            category: Category.Politics,
            name: "Politics"
        }));
        categories.push(CategoryList({
            category: Category.Regional_News,
            name: "Regional News"
        }));
        categories.push(CategoryList({
            category: Category.Religion_and_Spirituality,
            name: "Religion & Spirituality"
        }));
        categories.push(CategoryList({
            category: Category.Sports,
            name: "Sports"
        }));
        categories.push(CategoryList({
            category: Category.Technology,
            name: "Technology"
        }));
        categories.push(CategoryList({
            category: Category.Traffic_Roads,
            name: "Traffic & Roads"
        }));
        categories.push(CategoryList({
            category: Category.Weather,
            name: "Weather"
        }));
        categories.push(CategoryList({
            category: Category.Weblogs,
            name: "Web Blogs"
        }));
    }

    modifier isWhitelisted() {
        require(whitelisted[msg.sender],"not authorized");
        _;
    }

    function addPublisher(address publisher)
        public
        okOwner
    {
        require(whitelisted[publisher] == false,"already registered");
        whitelisted[publisher] = true;
    }

    function disablePublisher(address publisher)
        public
        okOwner
    {
        require(whitelisted[publisher],"already disabled");
        whitelisted[publisher] = false;
    }

    function addStory(address _reporter,
                      Category _category,
                      string memory _title,
                      uint256 _epoch,
                      string memory _topic1,
                      string memory _topic2,
                      string memory _topic3)
        public
        payable
        isWhitelisted
    {
        require(storytimes[_epoch] == address(0),"new stories already published in that time slot");
        require(msg.value == 0.00005 ether,"not enough for payment");
        payable(address(this)).transfer(msg.value);

        StoryNews memory news = StoryNews(msg.sender,_category,_title,_epoch,_topic1,_topic2,_topic3);
        newslist[_reporter][_epoch].push(news);
        storytimes[_epoch] = msg.sender;
        _storytimes.push(_epoch);
        totalSupply++;
    }

    function getStories(address _reporter,uint256 _epoch)
        public
        payable
        returns (StoryNews[] memory)
    {
        require(storytimes[_epoch] != address(0),"no new stories published for that time slot");
        require(msg.value == 0.0001 ether,"not enough for payment");
        payable(address(this)).transfer(msg.value);
        payable(storytimes[_epoch]).transfer(0.00005 ether); // transfer half of the polling fee to the publisher
        return newslist[_reporter][_epoch];
    }

    function getStoryTimes()
        public
        view
        returns (uint256[] memory)
    {
        return _storytimes;
    }

    function cashOut()
        public
        okOwner
    {
        require(address(this).balance > 0, "not enough balance to cash out");
        payable(msg.sender).transfer(address(this).balance);
    }
}