# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.config ||= {}
WickedPdf.config.merge!({
  # Path to the wkhtmltopdf executable: This usually isn't needed if using
  # one of the wkhtmltopdf-binary family of gems.
  # exe_path: '/usr/local/bin/wkhtmltopdf',
  #   or
  # exe_path: Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')

  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  # layout: 'pdf.html',
  layout: 'pdf',
  page_height: '155mm',
  page_width:  '105mm',
  orientation: "Portrait",
  # zoom: 1,
  # dpi: 203,
  zoom:0.78125,
  margin: {top:0,bottom:0,left:0,right:0},
  encoding: 'utf8',
  disable_smart_shrinking: true
})
