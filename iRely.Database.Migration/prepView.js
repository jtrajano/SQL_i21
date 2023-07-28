const fs = require('fs');
const path = require('path');

const folderPath = './logic/views'; // Replace with the path to your folder

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
    return content.replace(/CREATE\s+VIEW/gi, 'CREATE OR ALTER VIEW');
}


