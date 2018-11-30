import com.emergentspace.nexus.gmsec.MessageBody;
import org.apache.activemq.ActiveMQConnection;
import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.*;

public class JMSListener implements MessageListener{

    public Topic           topic;
    public TopicSession    topicSession;
    public TopicConnection topicConnection;

    public final String hostname = "tcp://localhost:61616";


    public JMSListener(String topicName) throws JMSException {

        // init JMS connection factory
        ActiveMQConnectionFactory connectionFactory
                = new ActiveMQConnectionFactory(ActiveMQConnection.DEFAULT_USER,
                                                ActiveMQConnection.DEFAULT_PASSWORD,
                                                this.hostname);

        // init the JMS session/topic
        this.topicConnection = connectionFactory.createTopicConnection();
        this.topicSession    = topicConnection.createTopicSession(false, TopicSession.AUTO_ACKNOWLEDGE);
        this.topic           = topicSession.createTopic(topicName);

        // create a message consumer from the topic session
        MessageConsumer consumer  = topicSession.createSubscriber(this.topic);

        // add ourselves as a listener (calls onMessage)
        consumer.setMessageListener(this);

        // finally start listening for messages
        this.topicConnection.start();
    }

    @Override
    public void onMessage(Message message) {

        // create text message
        TextMessage textMessage = (TextMessage)message;

        // raw message
        try {
            System.out.println(textMessage.getText());
        } catch (JMSException e) {
            e.printStackTrace();
        }

        // create a MessageBody object from the JMS message
        MessageBody messageBody = new MessageBody(textMessage);

        // toXML inserts newline
        MessageBody.prettyPrint = true;

        // print out the message body
        System.out.println(messageBody.toXML());
    }

    public static void main(String args[]) throws JMSException {

        JMSListener jmsListener = new JMSListener("NEXUS.>");
    }
}
