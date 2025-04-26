// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FreelanceDApp {
    enum JobStatus { Open, InProgress, Completed }

    struct Job {
        uint id;
        address client;
        string title;
        string description;
        uint payment;
        address payable freelancer;
        JobStatus status;
    }

    uint public jobCount = 0;
    mapping(uint => Job) public jobs;

    event JobPosted(uint indexed jobId, address indexed client, string title);
    event JobAccepted(uint indexed jobId, address indexed freelancer);
    event JobCompleted(uint indexed jobId, address indexed freelancer);

    modifier onlyClient(uint _jobId) {
        require(msg.sender == jobs[_jobId].client, "Only client can perform this action");
        _;
    }

    modifier onlyFreelancer(uint _jobId) {
        require(msg.sender == jobs[_jobId].freelancer, "Only assigned freelancer can perform this action");
        _;
    }

    // This Function helps in posting the job

    function postJob(string memory _title, string memory _description) public payable {
        require(msg.value > 0, "Payment must be greater than zero");

        jobs[jobCount] = Job({
            id: jobCount,
            client: msg.sender,
            title: _title,
            description: _description,
            payment: msg.value,
            freelancer: payable(address(0)),
            status: JobStatus.Open
        });

        emit JobPosted(jobCount, msg.sender, _title);
        jobCount++;
    }

    // This function helps in accepting the job
    function acceptJob(uint _jobId) public {
        Job storage job = jobs[_jobId];
        require(job.status == JobStatus.Open, "Job is not open for acceptance");

        job.freelancer = payable(msg.sender);
        job.status = JobStatus.InProgress;

        emit JobAccepted(_jobId, msg.sender);
    }

    function completeJob(uint _jobId) public onlyClient(_jobId) {
        Job storage job = jobs[_jobId];
        require(job.status == JobStatus.InProgress, "Job is not in progress");

        job.status = JobStatus.Completed;
        job.freelancer.transfer(job.payment);

        emit JobCompleted(_jobId, job.freelancer);
    }

    
    function getJob(uint _jobId) public view returns (
        uint, address, string memory, string memory, uint, address, JobStatus
    ) {
        Job memory job = jobs[_jobId];
        return (
            job.id, job.client, job.title, job.description, job.payment,
            job.freelancer, job.status
        );
    }
}
