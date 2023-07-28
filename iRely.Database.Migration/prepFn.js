const fs = require('fs');
const path = require('path');

const folderPath = './logic/functions'; // Replace with the path to your folder


const header = `--liquibase formatted sql

-- changeset Von:fnRKConvertMiscFieldString.1 runOnChange:true splitStatements:false
-- comment: RK-1234`;

fs.readdirSync(folderPath).forEach((file) => {
  if (file.endsWith('.sql')) {
    const filePath = path.join(folderPath, file);
    const fileContent = fs.readFileSync(filePath, 'utf8');

    const updatedContent = addHeaderIfNeeded(file, fileContent);

    const removeGoContent = updatedContent.replace(/\nGO\b/g, '\n');
    const finalContent = replaceCreateProcedure(removeGoContent);

    fs.writeFileSync(filePath, finalContent, 'utf8');
  }
});

function removeDuplicateHeader(content) {
  const lines = content.split(/\r?\n/);
  let inHeader = false;
  let headerLineCount = 0;
  const newLines = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();

    if (line.startsWith('--liquibase formatted sql')) {
      if (!inHeader) {
        inHeader = true;
        headerLineCount = 1;
        newLines.push(line);
      }
    } else if (inHeader && headerLineCount < 3) {
      // Skip lines 2 and 3 of the header
      headerLineCount++;
    } else {
      // Not in the header anymore, so add the line to the newLines
      newLines.push(lines[i]);
    }
  }

  return newLines.join('\n');
}

function addHeaderIfNeeded(fileName, content) {
  const header = `--liquibase formatted sql\n\n-- changeset Von:${fileName}.1 runOnChange:true splitStatements:false\n-- comment: RK-1234`;

  // Check if the header is already present at the beginning
  if (!content.startsWith('--liquibase formatted sql')) {
    return header + '\n\n' + content;
  } else {
    return content;
  }
}

function replaceCreateProcedure(content) {
    // Using regex with the "i" flag to perform case-insensitive replacement
    return content.replace(/CREATE\s+FUNCTION/gi, 'CREATE OR ALTER FUNCTION');
}


