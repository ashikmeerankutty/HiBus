import React from 'react';
import { Container } from 'react-bootstrap';

import './styles.scss';
import TestForm from './TestForm';

const HomePage = () => {
    return (
        <Container>
            <section id="home">
                <div className="text-center">
                    <p>Hello World!</p>
                    <TestForm />
                </div>
            </section>
        </Container>
    );
};

export default HomePage;
