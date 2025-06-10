ORM = {}



function ORM.instantiateDBTables()
    local result = MySQL.query.await("SELECT 1 FROM information_schema.tables WHERE TABLE_NAME = ?", {"drug_runs"})
    print(result[1])

    if not result[1] then 
        DebugPrint(('[^5] Initializing database tables for %s [^7]'):format(dbName))
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS drug_runs (
                appid INT AUTO_INCREMENT PRIMARY KEY,
                license VARCHAR(255) NOT NULL,
                cid VARCHAR(50) NOT NULL,
                xpAmount INT NOT NULL
            );
        ]])
    else
        return
    end
end


function ORM.updateXPAmount(license, xpAmount)
    local result = MySQL.query.await("SELECT xpAmount FROM drug_runs WHERE license = ?", {license})
    
    if result[1] then
        MySQL.update.await("UPDATE drug_runs SET xpAmount = xpAmount + ? WHERE license = ?", {xpAmount, license})
        DebugPrint(('XP amount updated for license %s to %d'):format(license, xpAmount))
        return true
    elseif not result[1] then
        MySQL.insert.await("INSERT INTO drug_runs (license, xpAmount) VALUES (?, ?)", {license, xpAmount})
        DebugPrint(('XP amount initialized for license %s with %d'):format(license, xpAmount))
        return true
    end
    return false 
end
