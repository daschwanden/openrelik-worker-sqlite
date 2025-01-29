# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import shutil
import subprocess
import time

from openrelik_worker_common.file_utils import create_output_file
from openrelik_worker_common.task_utils import create_task_result, get_input_files

from .app import celery

# Task name used to register and route the task to the correct queue.
TASK_NAME = "openrelik-worker-sqlite.tasks.sqlite"

# Task metadata for registration in the core system.
TASK_METADATA = {
    "display_name": "SQLite Worker",
    "description": "Exports SQLite Tables to CSV",
    # Configuration that will be rendered as a web for in the UI, and any data entered
    # by the user will be available to the task function when executing (task_config).
    "task_config": [
        {
            "name": "forensic_artifact",
            "label": "Select a Forensic Artifact to extract",
            "description": "The Forensic Artifact",
            "items": [ "None", "Exec Policy", "KnowledgeC DB", "Quarantine DB", "SystemPolicy DB", "TCC DB" ],
            "type": "select",  # Types supported: text, textarea, checkbox
            "required": False,
        },
    ],
}

INTERVAL_SECONDS = 2

@celery.task(bind=True, name=TASK_NAME, metadata=TASK_METADATA)
def command(
    self,
    pipe_result: str = None,
    input_files: list = None,
    output_path: str = None,
    workflow_id: str = None,
    task_config: dict = None,
) -> str:
    """Run /usr/bin/ls on input files.

    Args:
        pipe_result: Base64-encoded result from the previous Celery task, if any.
        input_files: List of input file dictionaries (unused if pipe_result exists).
        output_path: Path to the output directory.
        workflow_id: ID of the workflow.
        task_config: User configuration for the task.

    Returns:
        Base64-encoded dictionary containing task results.
    """
    input_files = get_input_files(pipe_result, input_files or [])
    output_files = []
    forensic_artifact = task_config.get("forensic_artifact", "")

    base_command = ["/openrelik/scripts/sqlite2csv.sh"]
    if forensic_artifact == "Exec Policy":
        base_command = ["/openrelik/scripts/execPolicy2csv.sh"]
    elif forensic_artifact ==  "KnowledgeC DB":
        base_command = ["/openrelik/scripts/knowledgeC2csv.sh"]
    elif forensic_artifact ==  "Quarantine DB":
        base_command = ["/openrelik/scripts/quarantine2csv.sh"]
    elif forensic_artifact ==  "SystemPolicy DB":
        base_command = ["/openrelik/scripts/systemPolicy2csv.sh"]
    elif forensic_artifact ==  "TCC DB":
        base_command = ["/openrelik/scripts/tcc2csv.sh"]

    base_command_string = " ".join(base_command)

    for input_file in input_files:
        output_file = create_output_file(
            output_path,
            display_name=input_file.get("display_name"),
            extension="txt",
        )
        command = base_command + [input_file.get("path")]

        # Run the command
        with open(output_file.path, "w") as fh:
            process = subprocess.Popen(command, stdout=fh)

        while process.poll() is None:
                self.send_event("task-progress", data=None)
                time.sleep(INTERVAL_SECONDS)
        
        filenames = os.listdir(os.getcwd())
        for csvfile in filenames:
            if csvfile.endswith(".csv"):
                csv_output_file = create_output_file(
                    output_path,
                    display_name=csvfile
                )
                shutil.move(csvfile, csv_output_file.path)
                output_files.append(csv_output_file.to_dict())

        output_files.append(output_file.to_dict())

    if not output_files:
        raise RuntimeError("Failed to export any tables.")

    return create_task_result(
        output_files=output_files,
        workflow_id=workflow_id,
        command=base_command_string,
        meta={},
    )
