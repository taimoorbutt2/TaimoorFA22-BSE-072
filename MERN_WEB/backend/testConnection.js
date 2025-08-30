const { MongoClient, ServerApiVersion } = require('mongodb');

const uri = "mongodb+srv://artisanmart:RguZrmI58JXxqgyl@artisanmartcluster.8lgia9b.mongodb.net/?retryWrites=true&w=majority&appName=ArtisanMartCluster";

// Create a MongoClient with a MongoClientOptions object to set the Stable API version
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

async function run() {
  try {
    // Connect the client to the server (optional starting in v4.7)
    await client.connect();
    // Send a ping to confirm a successful connection
    await client.db("admin").command({ ping: 1 });
    console.log("✅ Pinged your deployment. You successfully connected to MongoDB!");
    
    // Test connecting to our specific database
    const db = client.db("artisanmart");
    console.log("✅ Connected to database: artisanmart");
    
    // List collections to see what's there
    const collections = await db.listCollections().toArray();
    console.log("📚 Collections found:", collections.map(c => c.name));
    
  } catch (error) {
    console.error("❌ Connection failed:", error.message);
  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
  }
}

run().catch(console.dir);
