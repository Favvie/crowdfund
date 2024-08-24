// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Crowdfunding {
    // define the fields necessary for a campaign
    struct Campaign {
    string title;
    string description;
    address payable benefactor;
    uint goal;
    uint deadline ;
    uint amountRaised;
    }

    // a mapping that holds a reference to each campaign using the title of the campaign
    mapping (string => Campaign) internal campaigns;

    // an event that gets emitted when a new campaign is created
    event CampaignCreated(string campaignTitle);

    // an event that gets emitted when a donation is made to a specific campaign
    event DonationReceived(string campaignTitle, uint amount);

    // an event that gets emitted when a campaign is ends
    event CampaignEnded(string campaignTitle);

    // Function to create a new crowdfunding campaign
    function createCampaign(string memory _title, string memory _description, address payable _benefactor, uint _goal, uint _duration ) public { 
        
        // Calculate the campaign's deadline by adding the duration (in seconds) to the current block timestamp
        uint deadline = _duration + block.timestamp;
        
        // Ensure the campaign has a non-empty title
        require(bytes(_title).length > 0, "Campaign must have a title");
        
        // Ensure the fundraising goal is greater than zero
        require(_goal > 0, "Your goal must be greater than zero");
        
        // Create a new campaign and store it in the 'campaigns' mapping using the title as the key
        // The campaign is initialized with the provided title, description, benefactor, goal, and deadline
        // The 'amountRaised' is initially set to 0
        campaigns[_title] = Campaign(_title, _description, _benefactor, _goal, deadline, 0);
        
        // Emit an event to signal that a new campaign has been created
        emit CampaignCreated(_title);
}

    // Function to allow users to donate to a specific crowdfunding campaign
    function donateToCampaign(string memory _campaignTitle) payable public {
        
        // Access the campaign from storage using the provided title as the key
        Campaign storage campaign = campaigns[_campaignTitle];
        
        // Ensure that the campaign is still active by checking that the current time is before the deadline
        require(block.timestamp < campaign.deadline, 'Campaign has ended');
        
        // Increment the total amount raised for this campaign by the donation amount
        campaign.amountRaised += msg.value;
        
        // Emit an event to log the donation, including the campaign title and the donated amount
        emit DonationReceived(_campaignTitle, msg.value);

    }

    // Function to retrieve information about a specific campaign
    function getCampaignInfo(string memory _campaignTitle) public view returns (Campaign memory) {
        
        // Access the campaign from storage using the provided title as the key
        Campaign storage campaign = campaigns[_campaignTitle];
        
        // Return the campaign struct containing all its details
        return campaign;


    }

    // Function to end a campaign and transfer the funds to the benefactor
    function endCampaign(string memory _campaignTitle) public {

        // Access the campaign from storage using the provided title as the key
        Campaign storage campaign = campaigns[_campaignTitle];

        // Ensure that the campaign's deadline has passed before allowing the campaign to be ended
        require(campaign.deadline < block.timestamp, "Campaign has not ended");
        
        // Ensure that there are funds raised before attempting to transfer anything
        require(campaign.amountRaised > 0, "No funds to transfer");

        // Transfer the amount raised to the campaign's benefactor
        campaign.benefactor.transfer(campaign.amountRaised);
        
        // Emit an event indicating that the campaign has ended
        emit CampaignEnded(_campaignTitle);


    }
}