def an_email_was_sent_with_template(template_id)
  expect(Services.notify_client).to have_received(:send_email).with(hash_including(template_id:))
end

def an_sms_was_sent_with_template(template_id)
  expect(Services.notify_client).to have_received(:send_sms).with(hash_including(template_id:))
end
