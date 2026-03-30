/**
 * ============================================
 * TWENTY CRM ↔ GOOGLE SHEETS SYNCHRONIZATION
 * ============================================
 * 
 * This Apps Script syncs contacts and deals between:
 * - Twenty CRM API (crm.grainee.com/api)
 * - Google Sheets (data bus)
 * - Supabase (GRAINEE backend)
 * 
 * Setup:
 * 1. Create new Apps Script project
 * 2. Copy all functions below
 * 3. Set configuration constants
 * 4. Deploy as web app (execute as user)
 * 5. Add webhook to Twenty CRM
 * 6. Set up time-based triggers
 */

// ========== CONFIGURATION ==========

const CONFIG = {
  // Twenty CRM
  TWENTY_API_URL: 'https://crm.grainee.com/api',
  TWENTY_API_TOKEN: 'YOUR_TWENTY_API_TOKEN_HERE',
  
  // Google Sheets
  SPREADSHEET_ID: 'YOUR_SPREADSHEET_ID_HERE',
  SHEETS: {
    CONTACTS: 'Contacts',
    DEALS: 'Deals',
    ACTIVITIES: 'Activities',
    SYNC_LOG: 'SyncLog'
  },
  
  // Supabase
  SUPABASE_URL: 'https://lwyumrgygbuowndwcsvc.supabase.co',
  SUPABASE_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx3eXVtcmd5Z2J1b3duZHdjc3ZjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTQzMTMxMCwiZXhwIjoyMDg1MDA3MzEwfQ.-dYeNVWiX-L6mFToFlOq_WWfBmPG5RW-ct6Bd0-Nqh0',
  
  // Projects mapping
  PROJECTS: {
    'GRAINEE': 'grainee_workspace_id',
    'ROVLEX': 'rovlex_workspace_id',
    'ARBITR': 'arbitr_workspace_id'
  }
};

// ========== CONTACTS SYNC ==========

/**
 * Fetch all contacts from Twenty CRM and sync to Sheets
 */
function syncContactsFromTwenty() {
  Logger.log('Starting contacts sync from Twenty...');
  
  const sheet = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID)
    .getSheetByName(CONFIG.SHEETS.CONTACTS);
  
  try {
    // Fetch contacts from Twenty API
    const contacts = fetchContactsFromTwenty();
    
    if (!contacts || contacts.length === 0) {
      logSync('CONTACTS', 'No contacts found', 'WARNING');
      return;
    }
    
    // Prepare data for Sheets
    const rows = contacts.map(contact => [
      contact.id,
      contact.name,
      contact.email,
      contact.phone,
      contact.company,
      contact.lastActivityDate || '',
      contact.createdAt,
      new Date().toISOString()
    ]);
    
    // Clear existing data and write new
    sheet.clearContents();
    if (rows.length > 0) {
      sheet.getRange(1, 1, 1, 8).setValues([
        ['ID', 'Name', 'Email', 'Phone', 'Company', 'Last Activity', 'Created', 'Synced']
      ]);
      
      sheet.getRange(2, 1, rows.length, 8).setValues(rows);
    }
    
    logSync('CONTACTS', `Synced ${rows.length} contacts`, 'SUCCESS');
    
  } catch (error) {
    Logger.log('Error syncing contacts: ' + error);
    logSync('CONTACTS', 'Sync failed: ' + error, 'ERROR');
  }
}

/**
 * Fetch contacts from Twenty API
 */
function fetchContactsFromTwenty() {
  const url = CONFIG.TWENTY_API_URL + '/graphql';
  
  const payload = {
    query: `
      query GetContacts {
        contacts {
          edges {
            node {
              id
              firstName
              lastName
              email
              phone
              company {
                name
              }
              lastActivityDate
              createdAt
            }
          }
        }
      }
    `
  };
  
  const options = {
    method: 'post',
    contentType: 'application/json',
    headers: {
      'Authorization': 'Bearer ' + CONFIG.TWENTY_API_TOKEN
    },
    payload: JSON.stringify(payload),
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  const result = JSON.parse(response.getContentText());
  
  if (response.getResponseCode() !== 200) {
    throw new Error('Twenty API error: ' + response.getContentText());
  }
  
  // Transform response
  return result.data.contacts.edges.map(edge => {
    const node = edge.node;
    return {
      id: node.id,
      name: node.firstName + ' ' + node.lastName,
      email: node.email,
      phone: node.phone,
      company: node.company?.name || '',
      lastActivityDate: node.lastActivityDate,
      createdAt: node.createdAt
    };
  });
}

// ========== DEALS SYNC ==========

/**
 * Fetch deals from Twenty CRM and sync to Sheets
 */
function syncDealsFromTwenty() {
  Logger.log('Starting deals sync from Twenty...');
  
  const sheet = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID)
    .getSheetByName(CONFIG.SHEETS.DEALS);
  
  try {
    const deals = fetchDealsFromTwenty();
    
    if (!deals || deals.length === 0) {
      logSync('DEALS', 'No deals found', 'WARNING');
      return;
    }
    
    const rows = deals.map(deal => [
      deal.id,
      deal.name,
      deal.stage,
      deal.amount || '',
      deal.expectedCloseDate || '',
      deal.ownerName || '',
      deal.accountName || '',
      new Date().toISOString()
    ]);
    
    sheet.clearContents();
    if (rows.length > 0) {
      sheet.getRange(1, 1, 1, 8).setValues([
        ['ID', 'Name', 'Stage', 'Amount', 'Expected Close', 'Owner', 'Account', 'Synced']
      ]);
      
      sheet.getRange(2, 1, rows.length, 8).setValues(rows);
    }
    
    logSync('DEALS', `Synced ${rows.length} deals`, 'SUCCESS');
    
  } catch (error) {
    Logger.log('Error syncing deals: ' + error);
    logSync('DEALS', 'Sync failed: ' + error, 'ERROR');
  }
}

/**
 * Fetch deals from Twenty API
 */
function fetchDealsFromTwenty() {
  const url = CONFIG.TWENTY_API_URL + '/graphql';
  
  const payload = {
    query: `
      query GetDeals {
        deals {
          edges {
            node {
              id
              name
              stage
              amount
              expectedCloseDate
              owner {
                firstName
                lastName
              }
              account {
                name
              }
            }
          }
        }
      }
    `
  };
  
  const options = {
    method: 'post',
    contentType: 'application/json',
    headers: {
      'Authorization': 'Bearer ' + CONFIG.TWENTY_API_TOKEN
    },
    payload: JSON.stringify(payload),
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  const result = JSON.parse(response.getContentText());
  
  if (response.getResponseCode() !== 200) {
    throw new Error('Twenty API error: ' + response.getContentText());
  }
  
  return result.data.deals.edges.map(edge => {
    const node = edge.node;
    return {
      id: node.id,
      name: node.name,
      stage: node.stage,
      amount: node.amount,
      expectedCloseDate: node.expectedCloseDate,
      ownerName: node.owner ? node.owner.firstName + ' ' + node.owner.lastName : '',
      accountName: node.account?.name || ''
    };
  });
}

// ========== SUPABASE SYNC ==========

/**
 * Sync GRAINEE monitored places (profiles) to Twenty CRM
 */
function syncGRAINEEProfilesToTwenty() {
  Logger.log('Starting GRAINEE profiles sync to Twenty...');
  
  try {
    // Fetch from GRAINEE Supabase
    const profiles = fetchFromSupabase('profiles', 'id, monitored_place_name, place_id, rating, review_count');
    
    if (!profiles || profiles.length === 0) {
      logSync('GRAINEE_SYNC', 'No profiles found in GRAINEE', 'WARNING');
      return;
    }
    
    // Create/update companies in Twenty for each profile
    for (const profile of profiles) {
      createOrUpdateCompanyInTwenty({
        externalId: profile.id,
        name: profile.monitored_place_name,
        description: `Place ID: ${profile.place_id}, Rating: ${profile.rating}, Reviews: ${profile.review_count}`,
        customFields: {
          placeId: profile.place_id,
          rating: profile.rating,
          reviewCount: profile.review_count
        }
      });
    }
    
    logSync('GRAINEE_SYNC', `Synced ${profiles.length} profiles from GRAINEE`, 'SUCCESS');
    
  } catch (error) {
    Logger.log('Error syncing GRAINEE profiles: ' + error);
    logSync('GRAINEE_SYNC', 'Sync failed: ' + error, 'ERROR');
  }
}

/**
 * Fetch data from Supabase
 */
function fetchFromSupabase(table, columns = '*') {
  const url = CONFIG.SUPABASE_URL + '/rest/v1/' + table + '?select=' + columns;
  
  const options = {
    method: 'get',
    headers: {
      'apikey': CONFIG.SUPABASE_KEY,
      'Authorization': 'Bearer ' + CONFIG.SUPABASE_KEY
    },
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  
  if (response.getResponseCode() !== 200) {
    throw new Error('Supabase error: ' + response.getContentText());
  }
  
  return JSON.parse(response.getContentText());
}

/**
 * Create or update company in Twenty
 */
function createOrUpdateCompanyInTwenty(companyData) {
  const url = CONFIG.TWENTY_API_URL + '/graphql';
  
  const payload = {
    query: `
      mutation CreateOrUpdateCompany($name: String!, $description: String) {
        createCompany(input: {
          name: $name
          description: $description
        }) {
          id
          name
        }
      }
    `,
    variables: {
      name: companyData.name,
      description: companyData.description
    }
  };
  
  const options = {
    method: 'post',
    contentType: 'application/json',
    headers: {
      'Authorization': 'Bearer ' + CONFIG.TWENTY_API_TOKEN
    },
    payload: JSON.stringify(payload),
    muteHttpExceptions: true
  };
  
  const response = UrlFetchApp.fetch(url, options);
  
  if (response.getResponseCode() !== 200) {
    throw new Error('Failed to create company: ' + response.getContentText());
  }
  
  return JSON.parse(response.getContentText());
}

// ========== WEBHOOK HANDLER ==========

/**
 * Handle webhooks from Twenty CRM
 * Deploy as web app (execute as user)
 */
function doPost(e) {
  try {
    const payload = JSON.parse(e.postData.contents);
    
    Logger.log('Webhook received: ' + payload.type);
    
    switch(payload.type) {
      case 'contact.created':
      case 'contact.updated':
        syncContactsFromTwenty();
        break;
        
      case 'deal.created':
      case 'deal.updated':
        syncDealsFromTwenty();
        break;
        
      case 'activity.created':
        logSync('ACTIVITY', `New activity: ${payload.data?.title}`, 'INFO');
        break;
        
      default:
        Logger.log('Unknown webhook type: ' + payload.type);
    }
    
    return ContentService.createTextOutput(JSON.stringify({success: true}))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch (error) {
    Logger.log('Webhook error: ' + error);
    return ContentService.createTextOutput(JSON.stringify({error: error.toString()}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// ========== SCHEDULED SYNCS ==========

/**
 * Master sync function (run every 30 minutes)
 */
function syncAll() {
  Logger.log('=== MASTER SYNC STARTED at ' + new Date() + ' ===');
  
  try {
    syncContactsFromTwenty();
    syncDealsFromTwenty();
    syncGRAINEEProfilesToTwenty();
    
    Logger.log('=== MASTER SYNC COMPLETED ===');
  } catch (error) {
    Logger.log('Master sync error: ' + error);
    logSync('MASTER_SYNC', 'Failed: ' + error, 'ERROR');
  }
}

// ========== LOGGING & MONITORING ==========

/**
 * Log sync events to SyncLog sheet
 */
function logSync(event, message, status = 'INFO') {
  try {
    const sheet = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID)
      .getSheetByName(CONFIG.SHEETS.SYNC_LOG);
    
    const row = [
      new Date().toISOString(),
      event,
      message,
      status
    ];
    
    sheet.appendRow(row);
    
    // Keep only last 500 logs
    const lastRow = sheet.getLastRow();
    if (lastRow > 510) {
      sheet.deleteRows(2, lastRow - 500);
    }
    
  } catch (error) {
    Logger.log('Error logging sync: ' + error);
  }
}

/**
 * Get sync status
 */
function getSyncStatus() {
  const sheet = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID)
    .getSheetByName(CONFIG.SHEETS.SYNC_LOG);
  
  const data = sheet.getRange(Math.max(2, sheet.getLastRow() - 9), 1, 10, 4).getValues();
  
  return {
    lastSyncs: data.map(row => ({
      timestamp: row[0],
      event: row[1],
      message: row[2],
      status: row[3]
    })),
    spreadsheetUrl: 'https://docs.google.com/spreadsheets/d/' + CONFIG.SPREADSHEET_ID
  };
}

// ========== SETUP HELPERS ==========

/**
 * Initialize sync - create sheets and triggers
 */
function initializeSync() {
  Logger.log('Initializing sync...');
  
  const ss = SpreadsheetApp.openById(CONFIG.SPREADSHEET_ID);
  
  // Create sheets if they don't exist
  [CONFIG.SHEETS.CONTACTS, CONFIG.SHEETS.DEALS, CONFIG.SHEETS.ACTIVITIES, CONFIG.SHEETS.SYNC_LOG]
    .forEach(sheetName => {
      if (!ss.getSheetByName(sheetName)) {
        ss.insertSheet(sheetName);
        Logger.log('Created sheet: ' + sheetName);
      }
    });
  
  // Schedule triggers
  ScriptApp.getProjectTriggers().forEach(trigger => ScriptApp.deleteTrigger(trigger));
  
  // Sync every 30 minutes
  ScriptApp.newTrigger('syncAll')
    .timeBased()
    .everyMinutes(30)
    .create();
  
  Logger.log('Sync initialized successfully');
}
