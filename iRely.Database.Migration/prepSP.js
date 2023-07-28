const fs = require('fs');
const path = require('path');

const folderPath = './logic/stored-procedures'; // Replace with the path to your folder


const header = `--liquibase formatted sql

-- changeset Von:uspAGCalculateWOTotal.1 runOnChange:true splitStatements:false
-- comment: AP-1234`;

fs.readdirSync(folderPath).forEach((file) => {
  if (file.endsWith('.sql')) {
    const filePath = path.join(folderPath, file);
    const fileContent = fs.readFileSync(filePath, 'utf8');
    const updatedContent = header + '\n\n' + fileContent;

    const removeGoContent = updatedContent.replace(/\nGO\b/g, '\n');

    const formattedContent = formatProcedure(removeGoContent);
    const finalContent = replaceCreateProcedure(formattedContent);

    fs.writeFileSync(filePath, finalContent, 'utf8');
  }
});

function replaceCreateProcedure(content) {
    // Using regex with the "i" flag to perform case-insensitive replacement
    return content.replace(/CREATE\s+PROCEDURE/gi, 'CREATE OR ALTER PROCEDURE');
  }


function formatProcedure(content) {
    const lines = content.split(/\r?\n/);
  let asFound = false;
  let endFound = false;
  let endIndex = -1;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim().toUpperCase();

    if (!asFound && line.startsWith('AS')) {
      // Check if 'BEGIN' already exists as the next word after 'AS'
      const nextLine = lines[i + 1].trim().toUpperCase();
      if (nextLine === 'BEGIN') {
        asFound = true;
      } else {
        // Add 'BEGIN' immediately after 'AS' if it doesn't exist
        lines.splice(i + 1, 0, 'BEGIN');
      }
      asFound = true;
    }

    if (line === 'END') {
      endFound = true;
      endIndex = i;
    }
  }

  if (!endFound || endIndex !== lines.length - 1) {
    // Add 'END' at the end of the file if it's missing or not at the end
    lines.push('END');
  }

  return lines.join('\n');
  }


