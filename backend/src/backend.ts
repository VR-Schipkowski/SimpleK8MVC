import express, { Request, Response } from "express";
import { Pool } from "pg";
import cors from "cors";

// Erstelle eine Express-Anwendung
const app = express();
const port = 8080;
app.use(cors());
app.use(express.json());

// PostgreSQL-Datenbankverbindung
const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: parseInt(process.env.DB_PORT || "5432"),
});
// Test-Route zum Überprüfen der Datenbankverbindung
app.get("/test-db-connection", async (req: Request, res: Response) => {
    try {
        const result = await pool.query("SELECT NOW()");
        res.json({ status: "success", time: result.rows[0] });
    } catch (error) {
        res.status(500).json({ status: "error", message: (error as Error).message });
    }
});

// Test backend läuft
app.get("/", async (req: Request, res: Response) => {
    res.json({ status: "success", message: "Backend is running" });
});
// Beispielroute zum Hinzufügen eines Benutzers
app.post("/add-user", async (req: Request, res: Response) => {
    const { name, email } = req.body;
    const result = await pool.query(
        "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *",
        [name, email]
    );
    res.json(result.rows[0]);
});

// Beispielroute zum Abrufen eines Benutzers
app.get("/get-user/:id", async (req: Request, res: Response) => {
    const { id } = req.params;
    const result = await pool.query("SELECT * FROM users WHERE id = $1", [id]);
    if (result.rows.length > 0) {
        res.json(result.rows[0]);
    } else {
        res.status(404).send("User not found");
    }
});

app.get("/get-users", async (req: Request, res: Response) => {
    const result = await pool.query("SELECT * FROM users");
    res.json(result.rows);
});

// Start der Express-App
app.listen(port, () => {
    console.log(`Backend listening at http://localhost:${port}`);
});