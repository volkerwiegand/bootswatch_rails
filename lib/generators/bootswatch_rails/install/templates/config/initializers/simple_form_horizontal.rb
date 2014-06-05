SimpleForm.setup do |config|
  config.form_class = 'simple_form form-horizontal'
  config.default_wrapper = :horizontal_form
  config.input_mappings = {
    /picture/ => :file,
    /document/ => :file,
  }
  config.wrapper_mappings = {
    check_boxes:   :horizontal_radio_and_checkboxes,
    radio_buttons: :horizontal_radio_and_checkboxes,
    file:          :horizontal_file_input,
    boolean:       :horizontal_boolean
  }
  config.error_notification_class = 'alert alert-danger'
end
