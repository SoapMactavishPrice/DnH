global class LeadCreationEmailService implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            // 1. Extract and validate sender email from email.fromAddress using regex
            String rawSender = email.fromAddress;
            String senderEmail = '';

            // Extract first valid email found in the fromAddress string
            Pattern pattern = Pattern.compile('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}');
            Matcher matcher = pattern.matcher(rawSender);
            if (matcher.find()) {
                senderEmail = matcher.group(0);
            } else {
                throw new EmailException('No valid email address found in: ' + rawSender);
            }

            // Trim email to max 80 characters if needed
            if (senderEmail.length() > 80) {
                senderEmail = senderEmail.substring(0, 80);
            }

            // 2. Extract subject and email body
            String subject = email.subject != null ? email.subject : 'No Subject';
            String emailBody = email.plainTextBody != null ? email.plainTextBody : '';

            // 3. Extract First and Last Name from email.fromName
            String fromName = email.fromName != null ? email.fromName.trim() : 'Unknown Sender';
            String firstName = 'Email';
            String lastName = 'Unknown';

            if (fromName.contains(' ')) {
                List<String> nameParts = fromName.split(' ', 2);
                firstName = nameParts[0];
                lastName = nameParts[1];
            } else {
                lastName = fromName;
            }

            // 4. Check if Lead with same email exists
            List<Lead> existingLeads = [
                SELECT Id, FirstName, LastName, Description 
                FROM Lead 
                WHERE Email = :senderEmail 
                LIMIT 1
            ];

            if (!existingLeads.isEmpty()) {
                // Update existing Lead
                Lead existingLead = existingLeads[0];
                existingLead.FirstName = firstName;
                existingLead.LastName = lastName;
                //existingLead.Description = (existingLead.Description != null ? existingLead.Description + '\n\n' : '') +
                                           //'--- New Email ---\nSubject: ' + subject + '\n\n' + emailBody;
                update existingLead;
                
                //Insert Email Message
                
            } else {
                // Create new Lead
                Lead newLead = new Lead();
                newLead.FirstName = firstName;
                newLead.LastName = lastName;
                newLead.Company = 'Unknown Company';
                newLead.Email = senderEmail;
                newLead.LeadSource = 'Email';
                //newLead.Description = 'Subject: ' + subject + '\n\n' + emailBody;
                insert newLead;
                
                //Insert Email Message
            }

            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error: ' + e.getMessage();
        }

        return result;
    }

    public class EmailException extends Exception {}
}