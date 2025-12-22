import { Component } from './api';
import { formatPriceBDT } from './currency';

interface BuildExportData {
  buildName: string;
  components: {
    category: string;
    component: Component | null;
  }[];
  totalPrice: number;
  compatibility?: {
    is_compatible: boolean;
    warnings: string[];
    errors: string[];
  } | null;
}

export async function exportBuildToPDF(data: BuildExportData): Promise<void> {
  // Create HTML content for PDF
  const htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>${data.buildName} - PC Build</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 40px;
          color: #333;
        }
        h1 {
          color: #2563eb;
          border-bottom: 3px solid #2563eb;
          padding-bottom: 10px;
        }
        .component {
          margin: 20px 0;
          padding: 15px;
          border: 1px solid #ddd;
          border-radius: 8px;
          background: #f9fafb;
        }
        .component-header {
          font-weight: bold;
          color: #1f2937;
          font-size: 14px;
          margin-bottom: 8px;
        }
        .component-name {
          font-size: 16px;
          margin-bottom: 5px;
        }
        .component-brand {
          color: #6b7280;
          font-size: 14px;
        }
        .component-price {
          color: #2563eb;
          font-weight: bold;
          margin-top: 8px;
        }
        .total {
          margin-top: 30px;
          padding: 20px;
          background: #eff6ff;
          border-radius: 8px;
          border: 2px solid #2563eb;
        }
        .total-label {
          font-size: 18px;
          font-weight: bold;
        }
        .total-price {
          font-size: 24px;
          color: #2563eb;
          font-weight: bold;
        }
        .compatibility {
          margin-top: 20px;
          padding: 15px;
          border-radius: 8px;
        }
        .compatible {
          background: #dcfce7;
          border: 1px solid #86efac;
          color: #166534;
        }
        .incompatible {
          background: #fee2e2;
          border: 1px solid #fca5a5;
          color: #991b1b;
        }
        .warning-item {
          margin: 5px 0;
          padding: 5px 0;
        }
        .footer {
          margin-top: 40px;
          text-align: center;
          color: #6b7280;
          font-size: 12px;
          border-top: 1px solid #ddd;
          padding-top: 20px;
        }
      </style>
    </head>
    <body>
      <h1>${data.buildName}</h1>
      <p>Generated on ${new Date().toLocaleDateString()}</p>
      
      <div class="components">
        ${data.components
          .filter(c => c.component)
          .map(c => `
            <div class="component">
              <div class="component-header">${c.category.toUpperCase()}</div>
              <div class="component-name">${c.component!.name}</div>
              ${c.component!.brand ? `<div class="component-brand">${c.component!.brand}</div>` : ''}
              <div class="component-price">
                ${c.component!.lowest_price_bdt ? formatPriceBDT(c.component!.lowest_price_bdt) : 'N/A'}
              </div>
            </div>
          `)
          .join('')}
      </div>
      
      <div class="total">
        <div class="total-label">Total Build Cost</div>
        <div class="total-price">${formatPriceBDT(data.totalPrice)}</div>
      </div>
      
      ${data.compatibility ? `
        <div class="compatibility ${data.compatibility.is_compatible && data.compatibility.errors.length === 0 ? 'compatible' : 'incompatible'}">
          <h3>${data.compatibility.is_compatible && data.compatibility.errors.length === 0 ? '✅ Build is Compatible' : '⚠️ Compatibility Issues'}</h3>
          ${data.compatibility.errors.length > 0 ? `
            <div>
              <strong>Errors:</strong>
              ${data.compatibility.errors.map(e => `<div class="warning-item">• ${e}</div>`).join('')}
            </div>
          ` : ''}
          ${data.compatibility.warnings.length > 0 ? `
            <div>
              <strong>Warnings:</strong>
              ${data.compatibility.warnings.map(w => `<div class="warning-item">• ${w}</div>`).join('')}
            </div>
          ` : ''}
        </div>
      ` : ''}
      
      <div class="footer">
        <p>Built with RigCheck PC Builder - https://rigcheck.com</p>
        <p>This build was exported on ${new Date().toLocaleString()}</p>
      </div>
    </body>
    </html>
  `;

  // Create a blob and download
  const blob = new Blob([htmlContent], { type: 'text/html' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `${data.buildName.replace(/[^a-z0-9]/gi, '_')}.html`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);

  // Show success message
  const { toast } = await import('sonner');
  toast.success('Build exported!', {
    description: 'Your build has been saved as an HTML file. You can open it in a browser and print to PDF.',
  });
}

export async function exportBuildToExcel(data: BuildExportData): Promise<void> {
  // Create CSV content
  let csvContent = 'Category,Component Name,Brand,Price (BDT)\n';
  
  data.components
    .filter(c => c.component)
    .forEach(c => {
      const price = c.component!.lowest_price_bdt 
        ? (typeof c.component!.lowest_price_bdt === 'string' 
            ? c.component!.lowest_price_bdt 
            : c.component!.lowest_price_bdt.toString())
        : 'N/A';
      
      csvContent += `"${c.category}","${c.component!.name}","${c.component!.brand || 'N/A'}","${price}"\n`;
    });
  
  csvContent += `\n"Total","","","${data.totalPrice}"\n`;
  
  if (data.compatibility) {
    csvContent += '\n"Compatibility Status"\n';
    csvContent += `"Compatible","${data.compatibility.is_compatible && data.compatibility.errors.length === 0 ? 'Yes' : 'No'}"\n`;
    
    if (data.compatibility.errors.length > 0) {
      csvContent += '\n"Errors"\n';
      data.compatibility.errors.forEach(e => {
        csvContent += `"${e.replace(/"/g, '""')}"\n`;
      });
    }
    
    if (data.compatibility.warnings.length > 0) {
      csvContent += '\n"Warnings"\n';
      data.compatibility.warnings.forEach(w => {
        csvContent += `"${w.replace(/"/g, '""')}"\n`;
      });
    }
  }

  // Create blob and download
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `${data.buildName.replace(/[^a-z0-9]/gi, '_')}.csv`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);

  // Show success message
  const { toast } = await import('sonner');
  toast.success('Build exported!', {
    description: 'Your build has been saved as a CSV file. You can open it in Excel or Google Sheets.',
  });
}
