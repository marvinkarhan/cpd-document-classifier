import pypdf
import os
from dotenv import load_dotenv
import weaviate
load_dotenv()

# Get a list of all files and directories in ./files
path = os.path.join(os.path.dirname(__file__), 'files')
pdf_files = [os.path.join(dirpath, f) for (dirpath, dirnames, filenames) in os.walk(path) for f in filenames]
OPEN_AI_API_KEY = os.getenv("OPEN_AI_API_KEY")
EMBEDDING_MODEL = "text-embedding-ada-002"

def near_text_weaviate(query, collection_name):
  nearText = {
    "concepts": [query],
    "distance": 0.7,
  }
  properties = [
    "title", "content",
    "_additional {certainty distance}"
  ]
  query_result = (
    client.query
    .get(collection_name, properties)
    .with_near_text(nearText)
    .with_limit(20)
    .do()
  )["data"]["Get"][collection_name]
  print (f"Objects returned: {len(query_result)}")
  return query_result

def j_print(json_in):
  import json
  print(json.dumps(json_in, indent=2))

client = weaviate.Client("http://localhost:8080", additional_headers={"X-OpenAI-API-Key": OPEN_AI_API_KEY})
document_schema = {
    "class": "Document",
    "description": "A collection of documents",
    "vectorizer": "text2vec-openai",
    "moduleConfig": {
        "text2vec-openai": {
          "model": "ada",
          "modelVersion": "002",
          "type": "text"
        }
    },
    "properties": [{
        "name": "title",
        "description": "Title of the document",
        "dataType": ["string"]
    },
    {
        "name": "content",
        "description": "Contents of the document",
        "dataType": ["text"]
    }]
}

client.schema.delete_all()
client.schema.create_class(document_schema)
client.batch.configure(
    batch_size=100,
    dynamic=True,
    timeout_retries=3,
)
  
data = []
with client.batch as batch:
  for file in pdf_files:
    text = ""
    # Open the PDF file in read-binary mode
    with open(file, 'rb') as pdf_file:
      # Create a PyPDF2 object for the PDF file
      pdf_reader = pypdf.PdfReader(pdf_file)
      
      # Loop through each page in the PDF file and print its contents
      for page_num in range(len(pdf_reader.pages)):
        page = pdf_reader.pages[page_num]
        text += page.extract_text()

    file_dict = {
      "title": file,
      "content": text
    }
    data.append(file_dict)
    batch.add_data_object(file_dict, "Document")

print(f"Importing ({len(data)}) Articles complete")  

result = (
    client.query.aggregate("Document")
    .with_fields("meta { count }")
    .do()
)

def query_weaviate(query):
  print(f"Query: {query} --------------------------------------------------------------------------------")
  query_result = near_text_weaviate(query, "Document")
  counter = 0
  for document in query_result:
      counter += 1
      print(f"{counter}. { document['title']} (Certainty: {round(document['_additional']['certainty'],3) }) (Distance: {round(document['_additional']['distance'],3) })")
