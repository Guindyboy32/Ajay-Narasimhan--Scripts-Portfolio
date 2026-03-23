Step-by-Step: Uploading the CSV in Postman

Open the Collection Runner

In Postman, go to the top right of your collection (SNIPE ASSET UPDATE_(Name the collection of laptops that you got by date).

Click Runner (the ▶️ “Run” button).

Select the Collection

The Collection Runner window will open.

Make sure SNIPE ASSET UPDATE_(Name the collection of laptops that you got by date) is selected as the collection to run.

Attach the CSV File

Under the section “Data”, you’ll see an option to choose a file.

Click “Select File” or “Preview” (depending on your Postman version).

Choose your CSV file (in your case, Add to Snipe 642025.csv).

Verify Column Mapping

Postman will preview the CSV like in your screenshot (showing columns like serial, Model, asset_tag, etc.).

Each iteration (row) in the CSV will be passed as variables into your API request.

Reference Variables in the Request Body

In your API call’s Body, use double curly braces to map fields from the CSV:


Example of the field in the CSV. 

| serial   | Model      | ModelName                 | asset_tag    | status_id | model_id | name     | location_     |
| -------- | ---------- | ------------------------- | ------------ | --------- | -------- | -------- | ------------- |
| ASDasdas | DellLenovoCombo | HybridAwesome | TestDomain-ASDasdas | 2         | **138**  | ASDasdas | JurassicPark |


{
  "location_id": 3,  ---> Location 
  "name": "{{serial}}", --> Name match it in the CSV
  "status_id": 2, --> The Status of the Device
  "asset_tag": "{{asset_tag}}", --> TEST- (SN of the Device)
  "model_id": 136, --> (Update the number and model by checking Snipe)
  "serial": "{{serial}}",
  "category_id": 17,
  "_snipeit_lte_capable_8": "Yes",
  "_snipeit_warranty_expiry_7": "2028-04-18",
  "_snipeit_warranty_type_6": "DellLenovo Onsite"
}
