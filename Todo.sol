// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoTaskManager {
    struct Task {
        uint256 id;
        string name;
        string description;
        uint256 deadline;
        TaskStatus status;
    }

    enum TaskStatus { Pending, Completed, Deleted }

    address public admin;
    uint256 private nextTaskId;
    mapping(uint256 => Task) private tasks;
    uint256[] private taskIds;

    event TaskCreated(uint256 id, string name, string description, uint256 deadline);
    event TaskCompleted(uint256 id);
    event TaskDeleted(uint256 id);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
        nextTaskId = 1;
    }

    function createTask(string memory name, string memory description, uint256 deadline) public onlyAdmin {
        require(deadline > block.timestamp, "Deadline must be in the future");

        tasks[nextTaskId] = Task({
            id: nextTaskId,
            name: name,
            description: description,
            deadline: deadline,
            status: TaskStatus.Pending
        });
        taskIds.push(nextTaskId);

        emit TaskCreated(nextTaskId, name, description, deadline);
        nextTaskId++;
    }

    function markTaskCompleted(uint256 taskId) public onlyAdmin {
        require(tasks[taskId].id != 0, "Task does not exist");
        require(tasks[taskId].status == TaskStatus.Pending, "Task is not in a pending state");

        tasks[taskId].status = TaskStatus.Completed;

        emit TaskCompleted(taskId);
    }

    function deleteTask(uint256 taskId) public onlyAdmin {
        require(tasks[taskId].id != 0, "Task does not exist");
        require(tasks[taskId].status != TaskStatus.Deleted, "Task is already deleted");

        tasks[taskId].status = TaskStatus.Deleted;

        emit TaskDeleted(taskId);
    }

    function autoDeleteExpiredTasks() public {
        for (uint256 i = 0; i < taskIds.length; i++) {
            uint256 taskId = taskIds[i];
            if (tasks[taskId].deadline < block.timestamp && tasks[taskId].status == TaskStatus.Pending) {
                tasks[taskId].status = TaskStatus.Deleted;
                emit TaskDeleted(taskId);
            }
        }
    }

    function getTasksByStatus(TaskStatus status) public view returns (Task[] memory) {
        uint256 count;
        for (uint256 i = 0; i < taskIds.length; i++) {
            if (tasks[taskIds[i]].status == status) {
                count++;
            }
        }

        Task[] memory filteredTasks = new Task[](count);
        uint256 index;
        for (uint256 i = 0; i < taskIds.length; i++) {
            if (tasks[taskIds[i]].status == status) {
                filteredTasks[index] = tasks[taskIds[i]];
                index++;
            }
        }

        return filteredTasks;
    }

    function getTaskCounts() public view returns (uint256 pending, uint256 completed, uint256 deleted) {
        for (uint256 i = 0; i < taskIds.length; i++) {
            if (tasks[taskIds[i]].status == TaskStatus.Pending) {
                pending++;
            } else if (tasks[taskIds[i]].status == TaskStatus.Completed) {
                completed++;
            } else if (tasks[taskIds[i]].status == TaskStatus.Deleted) {
                deleted++;
            }
        }
    }

    function getTask(uint256 taskId) public view returns (Task memory) {
        require(tasks[taskId].id != 0, "Task does not exist");
        return tasks[taskId];
    }
}
