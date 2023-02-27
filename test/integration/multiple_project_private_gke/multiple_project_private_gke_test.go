/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package schedule_workflow

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestMultipleProjectPrivateGKE(t *testing.T) {
	const pipelinename = "google-pipeline-diff-gke-2-test"
	const target1 = "dev-4-test"
	const target2 = "prod-4-test"
	const region = "us-central1"
	const svc2 = "trigger-sa-4-test"
	bpt := tft.NewTFBlueprintTest(t)

	bpt.DefineVerify(func(assert *assert.Assertions) {

		bpt.DefaultVerify(assert)

		projectID := bpt.GetStringOutput("project_id")
		fmt.Println("project id ", projectID)
		target_projectID := bpt.GetStringOutput("target_project_id")
		fmt.Println("target project id", target_projectID)
		gcdpipeline := gcloud.Run(t, fmt.Sprintf(" deploy delivery-pipelines describe %s --project %s --region %s", pipelinename, projectID, region))
		gcdpipelinefullname := fmt.Sprintf("projects/%s/locations/%s/deliveryPipelines/%s", projectID, region, pipelinename)

		assert.Equal(gcdpipelinefullname, gcdpipeline.Get("Delivery Pipeline.name").String(), fmt.Sprintf("Pipeline is Valid"))

		gcdtarget1 := gcloud.Run(t, fmt.Sprintf(" deploy targets describe %s --project %s --region %s", target1, projectID, region))
		gcdtarget1fullname := fmt.Sprintf("projects/%s/locations/%s/targets/%s", projectID, region, target1)

		assert.Equal(gcdtarget1fullname, gcdtarget1.Get("Target.name").String(), fmt.Sprintf("Target1 is Valid"))

		gcdtarget2 := gcloud.Run(t, fmt.Sprintf(" deploy targets describe %s --project %s --region %s", target2, projectID, region))
		gcdtarget2fullname := fmt.Sprintf("projects/%s/locations/%s/targets/%s", projectID, region, target2)

		assert.Equal(gcdtarget2fullname, gcdtarget2.Get("Target.name").String(), fmt.Sprintf("Target2 is Valid"))


		gcdbindingsvc2 := gcloud.Run(t, fmt.Sprintf(" projects get-iam-policy  %s --flatten=bindings --filter=%s --format=\"value(bindings.role)\" ", projectID, svc2))
		fmt.Println(gcdbindingsvc2)
	})

	bpt.Test()
}
